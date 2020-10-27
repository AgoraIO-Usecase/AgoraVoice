package io.agora.education.impl.room

import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import io.agora.Constants.Companion.API_BASE_URL
import io.agora.Constants.Companion.APPID
import io.agora.base.callback.ThrowableCallback
import io.agora.base.network.BusinessException
import io.agora.education.api.EduCallback
import io.agora.education.api.room.EduRoom
import io.agora.education.api.room.data.*
import io.agora.education.api.user.EduStudent
import io.agora.education.api.user.data.EduUserInfo
import io.agora.education.api.user.data.EduUserRole
import io.agora.education.impl.util.Convert
import io.agora.education.api.statistics.AgoraError
import io.agora.education.api.stream.data.*
import io.agora.education.api.user.EduUser
import io.agora.education.api.user.data.EduChatState
import io.agora.education.impl.ResponseBody
import io.agora.education.impl.board.EduBoardImpl
import io.agora.education.impl.cmd.bean.CMDResponseBody
import io.agora.education.impl.cmd.CMDDispatch
import io.agora.education.impl.manager.EduManagerImpl
import io.agora.education.impl.network.RetrofitManager
import io.agora.education.impl.record.EduRecordImpl
import io.agora.education.impl.role.data.EduUserRoleStr
import io.agora.education.impl.room.data.EduRoomInfoImpl
import io.agora.education.impl.room.data.request.EduJoinClassroomReq
import io.agora.education.impl.room.data.response.*
import io.agora.education.impl.room.network.RoomService
import io.agora.education.impl.sync.RoomSyncHelper
import io.agora.education.impl.sync.RoomSyncSession
import io.agora.education.impl.user.EduStudentImpl
import io.agora.education.impl.user.EduUserImpl
import io.agora.education.impl.user.data.EduLocalUserInfoImpl
import io.agora.education.impl.user.network.UserService
import io.agora.education.impl.util.CommonUtil
import io.agora.rtc.Constants.*
import io.agora.rtc.models.ChannelMediaOptions
import io.agora.rte.RteEngineImpl
import io.agora.rte.listener.RteChannelEventListener
import io.agora.rtm.*

internal class EduRoomImpl(
        roomInfo: EduRoomInfo,
        roomStatus: EduRoomStatus
) : EduRoom(roomInfo, roomStatus), RteChannelEventListener {

    private val TAG = "EduRoomImpl"
    internal var syncSession: RoomSyncSession
    internal var cmdDispatch: CMDDispatch

    init {
        RteEngineImpl.createChannel(roomInfo.roomUuid, this)
        syncSession = RoomSyncHelper(this, roomInfo, roomStatus, 3)
        record = EduRecordImpl()
        board = EduBoardImpl()
        cmdDispatch = CMDDispatch(this)
        /**管理当前room*/
        EduManagerImpl.addRoom(this)
    }

    lateinit var rtcToken: String

    /**用户监听学生join是否成功的回调*/
    private var studentJoinCallback: EduCallback<EduStudent>? = null
    private lateinit var roomEntryRes: EduEntryRes
    lateinit var mediaOptions: RoomMediaOptions

    /**是否退出房间的标志*/
    private var leaveRoom: Boolean = false

    /**标识join过程是否完全成功*/
    var joinSuccess: Boolean = false

    /**标识join过程是否正在进行中*/
    var joining = false

    /**当前classRoom的classType(Main or Sub)*/
    var curClassType = ClassType.Sub

    /**entry接口返回的流信息(可能是上次遗留的也可能是本次autoPublish流也可能是在同步(或join)过程中添加的远端流)*/
    var defaultStreams: MutableList<EduStreamEvent> = mutableListOf()

    internal fun getCurRoomType(): RoomType {
        return (getRoomInfo() as EduRoomInfoImpl).roomType
    }

    internal fun getCurUserList(): MutableList<EduUserInfo> {
        return syncSession.eduUserInfoList
    }

    internal fun getCurRemoteUserList(): MutableList<EduUserInfo> {
        val list = mutableListOf<EduUserInfo>()
        syncSession.eduUserInfoList?.forEach {
            if (it != getLocalUser().userInfo) {
                list.add(it)
            }
        }
        return list
    }

    internal fun getCurStreamList(): MutableList<EduStreamInfo> {
        return syncSession.eduStreamInfoList
    }

    internal fun getCurRemoteStreamList(): MutableList<EduStreamInfo> {
        val list = mutableListOf<EduStreamInfo>()
        syncSession.eduStreamInfoList?.forEach {
            if (it.publisher != getLocalUser().userInfo) {
                list.add(it)
            }
        }
        return list
    }

    /**上课过程中，学生的角色目前不发生改变;
     * join流程包括请求加入classroom的API接口、加入rte、同步roomInfo、同步、本地流初始化成功，任何一步出错即视为join失败*/
    override fun joinClassroom(options: RoomJoinOptions, callback: EduCallback<EduStudent>) {
        this.curClassType = ClassType.Sub
        this.joining = true
        this.studentJoinCallback = callback

        val localUserInfo = EduLocalUserInfoImpl(options.userUuid,
                options.userName, options.roleType,
                true, null,
                mutableListOf(), System.currentTimeMillis())

        // 此处需要把localUserInfo设置进localUser中
        syncSession.localUser = EduStudentImpl(localUserInfo)
        (syncSession.localUser as EduUserImpl).eduRoom = this

        // 大班课强制不自动发流
        // AgoraVoice 不要求这一点
        // if (getCurRoomType() == RoomType.LARGE_CLASS) {
        //    options.closeAutoPublish()
        // }

        mediaOptions = options.mediaOptions

        // 根据classroomType和用户传的角色值转化出一个角色字符串来和后端交互
        val role = Convert.convertUserRole(localUserInfo.role, getCurRoomType(), curClassType)
        val eduJoinClassroomReq = EduJoinClassroomReq(
                localUserInfo.userName, role,
                mediaOptions.primaryStreamId.toString(),
                mediaOptions.publishType.value)

        RetrofitManager.instance()!!.getService(API_BASE_URL, UserService::class.java)
                .joinClassroom(APPID, getRoomInfo().roomUuid, localUserInfo.userUuid, eduJoinClassroomReq)
                .enqueue(RetrofitManager.Callback(0, object : ThrowableCallback<ResponseBody<EduEntryRes>> {
                    override fun onSuccess(res: ResponseBody<EduEntryRes>?) {
                        roomEntryRes = res?.data!!

                        // 解析返回的user相关数据
                        localUserInfo.userToken = roomEntryRes.user.userToken
                        rtcToken = roomEntryRes.user.rtcToken
                        RetrofitManager.instance()!!.addHeader("token", roomEntryRes.user.userToken)
                        localUserInfo.isChatAllowed = roomEntryRes.user.muteChat == EduChatState.Allow.value
                        localUserInfo.userProperties = roomEntryRes.user.userProperties
                        localUserInfo.streamUuid = roomEntryRes.user.streamUuid

                        // 把本地用户信息合并到本地缓存中(需要转换类型)
                        syncSession.eduUserInfoList.add(Convert.convertUserInfo(localUserInfo))

                        //获取用户可能存在的流信息待join成功后进行处理
                        roomEntryRes.user.streams?.let {
                            // 转换并合并流信息到本地缓存
                            val streamEvents = Convert.convertStreamInfo(it, this@EduRoomImpl);
                            defaultStreams.addAll(streamEvents)
                        }

                        // 解析返回的room相关数据并同步保存至本地
                        getRoomStatus().startTime = roomEntryRes.room.roomState.startTime
                        getRoomStatus().courseState = Convert.convertRoomState(roomEntryRes.room.roomState.state)
                        getRoomStatus().isStudentChatAllowed = Convert.extractStudentChatAllowState(
                                roomEntryRes.room.roomState.muteChat, getCurRoomType())
                        roomProperties = roomEntryRes.room.roomProperties

                        // 加入rte(包括rtm和rtc)
                        joinRte(rtcToken, roomEntryRes.user.streamUuid.toLong(),
                                mediaOptions.convert(), object : ResultCallback<Void> {
                            override fun onSuccess(p0: Void?) {
                                // 拉取全量数据
                                syncSession.fetchSnapshot(object : EduCallback<Unit> {
                                    override fun onSuccess(res: Unit?) {
                                        /**全量数据拉取并合并成功*/
                                        /**初始化本地流*/
                                        initOrUpdateLocalStream(roomEntryRes, mediaOptions, object : EduCallback<Unit> {
                                            override fun onSuccess(res: Unit?) {
                                                joinSuccess(syncSession.localUser, studentJoinCallback as EduCallback<EduUser>)
                                            }

                                            override fun onFailure(code: Int, reason: String?) {
                                                joinFailed(code, reason, studentJoinCallback as EduCallback<EduUser>)
                                            }
                                        })
                                    }

                                    override fun onFailure(code: Int, reason: String?) {
                                        joinFailed(code, reason, callback as EduCallback<EduUser>)
                                    }
                                })
                            }

                            override fun onFailure(p0: ErrorInfo?) {
                                joinFailed(p0?.errorCode!!, p0?.errorDescription, callback as EduCallback<EduUser>)
                            }
                        })
                    }

                    override fun onFailure(throwable: Throwable?) {
                        var error = throwable as? BusinessException
                        error = error ?: BusinessException(throwable?.message)
                        joinFailed(error?.code, error?.message
                                ?: throwable?.message, callback as EduCallback<EduUser>)
                    }
                }))
    }

    private fun joinRte(rtcToken: String, rtcUid: Long, channelMediaOptions: ChannelMediaOptions,
                        @NonNull callback: ResultCallback<Void>) {
        RteEngineImpl.setClientRole(getRoomInfo().roomUuid, CLIENT_ROLE_BROADCASTER)
        val rtcOptionalInfo: String = CommonUtil.buildRtcOptionalInfo(this)
        RteEngineImpl[getRoomInfo().roomUuid]?.join(rtcOptionalInfo, rtcToken, rtcUid, channelMediaOptions, callback)
    }

    private fun initOrUpdateLocalStream(classRoomEntryRes: EduEntryRes, roomMediaOptions: RoomMediaOptions,
                                        callback: EduCallback<Unit>) {
        /**初始化或更新本地用户的本地流*/
        val localStreamInitOptions = LocalStreamInitOptions(classRoomEntryRes.user.streamUuid,
                roomMediaOptions.isAutoPublish(), roomMediaOptions.isAutoPublish())
        Log.d(TAG, "initOrUpdateLocalStream " +
                "${localStreamInitOptions.enableMicrophone} " +
                "${localStreamInitOptions.enableCamera}")

        syncSession.localUser.initOrUpdateLocalStream(localStreamInitOptions, object : EduCallback<EduStreamInfo> {
            override fun onSuccess(streamInfo: EduStreamInfo?) {
                /**判断是否需要更新本地的流信息(因为当前流信息在本地可能已经存在)*/
//                val pos = streamExistsInLocal(streamInfo)
                val pos = Convert.streamExistsInList(streamInfo!!, getCurStreamList())
                if (pos > -1) {
                    getCurStreamList()[pos] = streamInfo!!
                }
                /**如果当前用户是观众则调用unPublishStream(刷新服务器上可能存在的旧流)*/
                val role = Convert.convertUserRole(syncSession.localUser.userInfo.role,
                        getCurRoomType(), curClassType)
                if (role == EduUserRoleStr.audience.value) {
                    callback.onSuccess(Unit)
                } else {
                    /**大班课场景下为audience,小班课一对一都是broadcaster*/
                    RteEngineImpl.setClientRole(getRoomInfo().roomUuid,
                            if (getCurRoomType() != RoomType.LARGE_CLASS)
                                CLIENT_ROLE_BROADCASTER
                            else CLIENT_ROLE_AUDIENCE
                    )

                    if (mediaOptions.isAutoPublish()) {
                        val code = RteEngineImpl.publish(getRoomInfo().roomUuid)
                        Log.e(TAG, "publish: $code")
                    }
                    callback.onSuccess(Unit)
                }
            }

            override fun onFailure(code: Int, reason: String?) {
                callback.onFailure(code, reason)
            }
        })
    }

    /**判断joining状态防止多次调用*/
    private fun joinSuccess(eduUser: EduUser, callback: EduCallback<EduUser>) {
        if (joining) {
            joining = false
            synchronized(joinSuccess) {
                Log.e(TAG, "加入房间成功:${getRoomInfo().roomUuid}")
                /**维护本地存储的在线人数*/
                getRoomStatus().onlineUsersCount = getCurUserList().size

                val localStreamEvents: MutableList<EduStreamEvent> = mutableListOf()
                val remoteStreamEvents: MutableList<EduStreamEvent> = mutableListOf()

                val defaultStreamsIterable = defaultStreams.iterator()
                while (defaultStreamsIterable.hasNext()) {
                    val element = defaultStreamsIterable.next()
                    if (element.modifiedStream.publisher == eduUser.userInfo) {
                        localStreamEvents.add(element)
                    } else {
                        remoteStreamEvents.add(element)
                    }
                }

                // Merge and callback local user info and streams
                eduUser.userInfo.streams.addAll(localStreamEvents)
                callback.onSuccess(eduUser as EduStudent)

                eventListener?.onRemoteUsersInitialized(getCurRemoteUserList(), this@EduRoomImpl)
                eventListener?.onRemoteStreamsInitialized(getCurRemoteStreamList(), this@EduRoomImpl)
                joinSuccess = true

                // Callback of local stream add
                val localStreamIterable = localStreamEvents.iterator()
                while (localStreamIterable.hasNext()) {
                    val elem = localStreamIterable.next()
                    val stream = elem.modifiedStream
                    RteEngineImpl.updateLocalStream(stream.hasAudio, stream.hasVideo)
                    eduUser.eventListener?.onLocalStreamAdded(elem)
                }

                // Callback of remote stream add
                if (defaultStreams.size > 0) {
                    eventListener?.onRemoteStreamsAdded(defaultStreams, this)
                }

                /**检查并处理缓存数据(处理CMD消息)*/
                (syncSession as RoomSyncHelper).handleCache(object : EduCallback<Unit> {
                    override fun onSuccess(res: Unit?) {

                    }

                    override fun onFailure(code: Int, reason: String?) {
                    }
                })
            }
        }
    }

    /**join失败的情况下，清楚所有本地已存在的缓存数据；判断joining状态防止多次调用
     * 并退出rtm和rtc*/
    private fun joinFailed(code: Int, reason: String?, callback: EduCallback<EduUser>) {
        if (joining) {
            joining = false
            synchronized(joinSuccess) {
                joinSuccess = false
                clearData()
                callback.onFailure(code, reason)
            }
        }
    }

    /**清楚本地缓存，离开RTM的当前频道；退出RTM*/
    override fun clearData() {
        getCurUserList().clear()
        getCurStreamList().clear()
    }

    override fun getLocalUser(): EduUser {
        return syncSession.localUser
    }

    override fun getRoomInfo(): EduRoomInfo {
        return syncSession.roomInfo
    }

    override fun getRoomStatus(): EduRoomStatus {
        return syncSession.roomStatus
    }

    override fun getStudentCount(): Int {
        return getStudentList().size
    }

    override fun getTeacherCount(): Int {
        return getTeacherList().size
    }

    override fun getStudentList(): MutableList<EduUserInfo> {
        val studentList = mutableListOf<EduUserInfo>()
        for (element in getFullUserList()) {
            if (element.role == EduUserRole.STUDENT) {
                studentList.add(element)
            }
        }
        return studentList
    }

    override fun getTeacherList(): MutableList<EduUserInfo> {
        val teacherList = mutableListOf<EduUserInfo>()
        for (element in getFullUserList()) {
            if (element.role == EduUserRole.TEACHER) {
                teacherList.add(element)
            }
        }
        return teacherList
    }

    override fun getFullStreamList(): MutableList<EduStreamInfo> {
        return syncSession.eduStreamInfoList
    }

    /**获取本地缓存的所有用户数据
     * 当第一个用户进入新房间(暂无用户的房间)的时候，不会有人流数据同步过来，此时如果调用此函数
     * 需要把本地用户手动添加进去*/
    override fun getFullUserList(): MutableList<EduUserInfo> {
//        if (roomSyncSession.eduUserInfoList.size == 0) {
//            /**把localUserInfo转换为userInfo，保持集合中数据类型统一*/
//            val userInfo = Convert.convertUserInfo(localUser.userInfo)
//            roomSyncSession.eduUserInfoList.add(userInfo)
//        }
        return syncSession.eduUserInfoList
    }

    override fun leave() {
        clearData()
        if (!leaveRoom) {
            RteEngineImpl[getRoomInfo().roomUuid]?.leave()
            leaveRoom = true
        }
        RteEngineImpl[getRoomInfo().roomUuid]?.release()
        eventListener = null
        syncSession.localUser.eventListener = null
        studentJoinCallback = null
        (getLocalUser() as EduUserImpl).removeAllSurfaceView()
        /**移除掉当前room*/
        EduManagerImpl.removeRoom(this)
    }

    override fun onChannelMsgReceived(p0: RtmMessage?, p1: RtmChannelMember?) {
        p0?.text?.let {
            val cmdResponseBody = Gson().fromJson<CMDResponseBody<Any>>(p0.text, object :
                    TypeToken<CMDResponseBody<Any>>() {}.type)
            val pair = syncSession.updateSequenceId(cmdResponseBody)
            if (pair != null) {
                syncSession.fetchLostSequence(pair.first, pair.second, object : EduCallback<Unit> {
                    override fun onSuccess(res: Unit?) {
                    }

                    override fun onFailure(code: Int, reason: String?) {
                    }
                })
            }
        }
    }

    override fun onNetworkQuality(uid: Int, txQuality: Int, rxQuality: Int) {
    }
}
