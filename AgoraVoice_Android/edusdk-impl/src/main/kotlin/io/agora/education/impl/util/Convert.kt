package io.agora.education.impl.util

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import io.agora.education.api.message.EduActionMessage
import io.agora.education.api.message.EduActionType
import io.agora.education.api.room.EduRoom
import io.agora.education.api.room.data.*
import io.agora.education.api.room.data.Property.Companion.KEY_ASSISTANT_LIMIT
import io.agora.education.api.room.data.Property.Companion.KEY_STUDENT_LIMIT
import io.agora.education.api.room.data.Property.Companion.KEY_TEACHER_LIMIT
import io.agora.education.api.statistics.ConnectionState
import io.agora.education.api.statistics.ConnectionStateChangeReason
import io.agora.education.api.stream.data.*
import io.agora.education.api.user.data.EduChatState
import io.agora.education.api.user.data.EduLocalUserInfo
import io.agora.education.api.user.data.EduUserInfo
import io.agora.education.api.user.data.EduUserRole
import io.agora.education.impl.cmd.bean.*
import io.agora.education.impl.cmd.bean.CMDActionMsgRes
import io.agora.education.impl.role.data.EduUserRoleStr
import io.agora.education.impl.room.data.response.*
import io.agora.education.impl.stream.EduStreamInfoImpl
import io.agora.education.impl.user.data.EduUserInfoImpl
import io.agora.education.impl.room.EduRoomImpl
import io.agora.education.impl.room.data.request.LimitConfig
import io.agora.education.impl.room.data.request.RoleConfig
import io.agora.education.impl.room.data.request.RoomCreateOptionsReq
import io.agora.education.impl.user.data.EduLocalUserInfoImpl
import io.agora.education.impl.user.data.request.RoleMuteConfig
import io.agora.rtc.video.VideoEncoderConfiguration
import io.agora.rtm.RtmStatusCode.ConnectionChangeReason.*
import io.agora.rtm.RtmStatusCode.ConnectionState.CONNECTION_STATE_DISCONNECTED

internal class Convert {
    companion object {

        fun convertRoomCreateOptions(roomCreateOptions: RoomCreateOptions): RoomCreateOptionsReq {
            var roomCreateOptionsReq = RoomCreateOptionsReq()
            roomCreateOptionsReq.roomName = roomCreateOptions.roomName

            val mRoleConfig = convertRoleConfig(roomCreateOptions)
            roomCreateOptionsReq.roleConfig = mRoleConfig
            return roomCreateOptionsReq
        }

        fun convertRoleConfig(roomCreateOptions: RoomCreateOptions): RoleConfig {

            val roleConfig = RoleConfig()
            var teacherLimit = 0
            var studentLimit = 0
            var assistantLimit = 0
            for (element in roomCreateOptions.roomProperties) {
                when (element.key) {
                    KEY_TEACHER_LIMIT -> {
                        teacherLimit = element.value.toInt() ?: 0
                    }
                    KEY_STUDENT_LIMIT -> {
                        studentLimit = element.value.toInt() ?: 0
                    }
                    KEY_ASSISTANT_LIMIT -> {
                        assistantLimit = element.value.toInt() ?: 0
                    }
                }
            }
            roleConfig.host = LimitConfig(teacherLimit)
            if (roomCreateOptions.roomType == RoomType.LARGE_CLASS.value) {
                roleConfig.audience = LimitConfig(studentLimit)
            } else if (roomCreateOptions.roomType == RoomType.BREAKOUT_CLASS.value) {
                /**目前，超级小班课情况下，移动端只可能创建大房间，小房间由服务端创建，所以此处学生的角色是audience
                 * */
                roleConfig.audience = LimitConfig(studentLimit)
                roleConfig.assistant = LimitConfig(assistantLimit)
            } else {
                roleConfig.broadcaster = LimitConfig(studentLimit)
            }
            return roleConfig
        }

        fun convertVideoEncoderConfig(videoEncoderConfig: VideoEncoderConfig): VideoEncoderConfiguration {
            var videoDimensions = VideoEncoderConfiguration.VideoDimensions(
                    videoEncoderConfig.videoDimensionWidth,
                    videoEncoderConfig.videoDimensionHeight)
            var videoEncoderConfiguration = VideoEncoderConfiguration()
            videoEncoderConfiguration.dimensions = videoDimensions
            videoEncoderConfiguration.frameRate = videoEncoderConfig.fps
            when (videoEncoderConfig.orientationMode) {
                OrientationMode.ADAPTIVE -> {
                    videoEncoderConfiguration.orientationMode = VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_ADAPTIVE
                }
                OrientationMode.FIXED_LANDSCAPE -> {
                    videoEncoderConfiguration.orientationMode = VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_LANDSCAPE
                }
                OrientationMode.FIXED_PORTRAIT -> {
                    videoEncoderConfiguration.orientationMode = VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_PORTRAIT
                }
            }
            when (videoEncoderConfig.degradationPreference) {
                DegradationPreference.MAINTAIN_QUALITY -> {
                    videoEncoderConfiguration.degradationPrefer = VideoEncoderConfiguration.DEGRADATION_PREFERENCE.MAINTAIN_QUALITY
                }
                DegradationPreference.MAINTAIN_FRAME_RATE -> {
                    videoEncoderConfiguration.degradationPrefer = VideoEncoderConfiguration.DEGRADATION_PREFERENCE.MAINTAIN_FRAMERATE
                }
                DegradationPreference.MAINTAIN_BALANCED -> {
                    videoEncoderConfiguration.degradationPrefer = VideoEncoderConfiguration.DEGRADATION_PREFERENCE.MAINTAIN_BALANCED
                }
            }
            return videoEncoderConfiguration
        }

        fun convertRoomType(roomType: Int): RoomType {
            return when (roomType) {
                RoomType.ONE_ON_ONE.value -> {
                    RoomType.ONE_ON_ONE
                }
                RoomType.SMALL_CLASS.value -> {
                    RoomType.SMALL_CLASS
                }
                RoomType.BREAKOUT_CLASS.value -> {
                    RoomType.BREAKOUT_CLASS
                }
                else -> {
                    RoomType.LARGE_CLASS
                }
            }
        }

        /**根据EduUserRole枚举返回角色字符串*/
        fun convertUserRole(role: EduUserRole, roomType: RoomType, classType: ClassType): String {
            return if (role == EduUserRole.TEACHER) {
                EduUserRoleStr.host.name
            } else {
                when (roomType) {
                    RoomType.ONE_ON_ONE -> {
                        EduUserRoleStr.broadcaster.name
                    }
                    RoomType.SMALL_CLASS -> {
                        EduUserRoleStr.broadcaster.name
                    }
                    RoomType.LARGE_CLASS -> {
                        EduUserRoleStr.audience.name
                    }
                    RoomType.BREAKOUT_CLASS -> {
                        when (classType) {
                            ClassType.Main -> {
                                EduUserRoleStr.audience.name
                            }
                            ClassType.Sub -> {
                                EduUserRoleStr.broadcaster.name
                            }
                        }
                    }
                }
            }
        }

        /**根据角色字符串返回EduUserRole枚举值*/
        fun convertUserRole(role: String, roomType: RoomType): EduUserRole {
            when (role) {
                EduUserRoleStr.host.name -> {
                    return EduUserRole.TEACHER
                }
                EduUserRoleStr.broadcaster.name -> {
                    if (roomType == RoomType.ONE_ON_ONE || roomType == RoomType.SMALL_CLASS ||
                            roomType == RoomType.BREAKOUT_CLASS) {
                        return EduUserRole.STUDENT
                    }
                }
                EduUserRoleStr.audience.name -> {
                    if (roomType == RoomType.LARGE_CLASS) {
                        return EduUserRole.STUDENT
                    } else if (roomType == RoomType.BREAKOUT_CLASS) {
                        return EduUserRole.STUDENT
                    }
                }
            }
            return EduUserRole.STUDENT
        }

        /**根据返回的用户和stream列表提取出用户列表*/
        fun getUserInfoList(eduUserListRes: EduUserListRes?, roomType: RoomType): MutableList<EduUserInfo> {
            val list = eduUserListRes?.list
            if (list?.size == 0) {
                return mutableListOf()
            }
            val userInfoList: MutableList<EduUserInfo> = mutableListOf()
            for ((index, element) in list?.withIndex()!!) {
                val eduUser = convertUserInfo(element, roomType)
                userInfoList.add(index, eduUser)
            }
            return userInfoList
        }

        fun convertUserInfo(eduUserRes: EduUserRes, roomType: RoomType): EduUserInfo {
            val role = convertUserRole(eduUserRes.role, roomType)
            return EduUserInfoImpl(eduUserRes.userUuid, eduUserRes.userName, role,
                    eduUserRes.muteChat == EduChatState.Allow.value, eduUserRes.updateTime)
        }

        fun convertUserInfo(eduUserRes: EduFromUserRes, roomType: RoomType): EduUserInfo {
            val role = convertUserRole(eduUserRes.role, roomType)
            return EduUserInfoImpl(eduUserRes.userUuid, eduUserRes.userName, role, false, null)
        }

        /**根据返回的用户和stream列表提取出stream列表*/
        fun getStreamInfoList(eduStreamListRes: EduStreamListRes?, roomType: RoomType): MutableList<EduStreamInfo> {
            val userResList = eduStreamListRes?.list
            if (userResList?.size == 0) {
                return mutableListOf()
            }
            val streamInfoList: MutableList<EduStreamInfo> = mutableListOf()
            for ((index, element) in userResList?.withIndex()!!) {
                val eduUserInfo = convertUserInfo(element.fromUser, roomType)
                val videoSourceType = if (element.videoSourceType == 1) VideoSourceType.CAMERA else VideoSourceType.SCREEN
                val hasVideo = element.videoState == EduVideoState.Open.value
                val hasAudio = element.audioState == EduAudioState.Open.value
                val eduStreamInfo = EduStreamInfoImpl(element.streamUuid, element.streamName, videoSourceType,
                        hasVideo, hasAudio, eduUserInfo, element.updateTime)
                streamInfoList.add(index, eduStreamInfo)
            }
            return streamInfoList
        }

        fun convertRoomState(state: Int): EduRoomState {
            return when (state) {
                EduRoomState.INIT.value -> {
                    EduRoomState.INIT
                }
                EduRoomState.START.value -> {
                    EduRoomState.START
                }
                EduRoomState.END.value -> {
                    EduRoomState.END
                }
                else -> {
                    EduRoomState.INIT
                }
            }
        }

        fun convertStreamInfo(eduStreamRes: EduStreamRes, roomType: RoomType): EduStreamInfo {
            val fromUserInfo = convertUserInfo(eduStreamRes.fromUser, roomType)
            return EduStreamInfoImpl(eduStreamRes.streamUuid, eduStreamRes.streamName,
                    convertVideoSourceType(eduStreamRes.videoSourceType),
                    eduStreamRes.videoState == EduVideoState.Open.value,
                    eduStreamRes.audioState == EduAudioState.Open.value,
                    fromUserInfo, eduStreamRes.updateTime)
        }

        fun convertStreamInfo(cmdStreamActionMsg: CMDStreamActionMsg, roomType: RoomType): EduStreamInfo {
            val fromUserInfo = convertUserInfo(cmdStreamActionMsg.fromUser, roomType)
            return EduStreamInfoImpl(cmdStreamActionMsg.streamUuid, cmdStreamActionMsg.streamName,
                    convertVideoSourceType(cmdStreamActionMsg.videoSourceType),
                    cmdStreamActionMsg.videoState == EduVideoState.Open.value,
                    cmdStreamActionMsg.audioState == EduAudioState.Open.value,
                    fromUserInfo, cmdStreamActionMsg.updateTime)
        }

        fun convertStreamInfo(streamResList: MutableList<EduEntryStreamRes>, eduRoom: EduRoom): MutableList<EduStreamEvent> {
            val streamEvents = mutableListOf<EduStreamEvent>()
            val eduStreamInfos = (eduRoom as EduRoomImpl).getCurStreamList()
            synchronized(eduStreamInfos) {
                streamResList.forEach {
                    val videoSourceType = convertVideoSourceType(it.videoSourceType)
                    val streamInfo = EduStreamInfoImpl(it.streamUuid, it.streamName, videoSourceType,
                            it.videoState == EduVideoState.Open.value,
                            it.audioState == EduAudioState.Open.value, eduRoom.getLocalUser().userInfo,
                            it.updateTime
                    )
                    /**整合流信息到本地缓存中*/
                    eduStreamInfos.add(streamInfo)
                    streamEvents.add(EduStreamEvent(streamInfo, null))
                }
                return streamEvents
            }
        }

        fun convertStreamInfo(syncStreamRes: CMDSyncStreamRes, eduUserInfo: EduUserInfo): EduStreamInfo {
            val videoSourceType = convertVideoSourceType(syncStreamRes.videoSourceType)
            val hasVideo = syncStreamRes.videoState == EduVideoState.Open.value
            val hasAudio = syncStreamRes.audioState == EduAudioState.Open.value
            return EduStreamInfoImpl(syncStreamRes.streamUuid,
                    syncStreamRes.streamName, videoSourceType, hasVideo, hasAudio, eduUserInfo,
                    syncStreamRes.updateTime)
        }

        fun convertVideoSourceType(value: Int): VideoSourceType {
            return when (value) {
                VideoSourceType.CAMERA.value -> {
                    VideoSourceType.CAMERA
                }
                VideoSourceType.SCREEN.value -> {
                    VideoSourceType.SCREEN
                }
                else -> {
                    VideoSourceType.CAMERA
                }
            }
        }

        fun convertUserInfo(cmdUserStateMsg: CMDUserStateMsg, roomType: RoomType): EduUserInfo {
            val role = convertUserRole(cmdUserStateMsg.role, roomType)
            return EduUserInfoImpl(cmdUserStateMsg.userUuid, cmdUserStateMsg.userName, role,
                    cmdUserStateMsg.muteChat == EduChatState.Allow.value,
                    cmdUserStateMsg.updateTime)
        }

        /**根据roomType提取muteChat(针对student而言)的状态*/
        fun extractStudentChatAllowState(muteChatConfig: RoleMuteConfig?, roomType: RoomType): Boolean {
            /**任何场景下，默认都允许学生聊天*/
            var allow = true
            when (roomType) {
                RoomType.ONE_ON_ONE, RoomType.SMALL_CLASS, RoomType.BREAKOUT_CLASS -> {
                    muteChatConfig?.broadcaster?.let {
                        allow = muteChatConfig?.broadcaster?.toInt() == EduMuteState.Enable.value
                    }
                }
                RoomType.LARGE_CLASS -> {
                    allow = muteChatConfig?.audience?.toInt() == EduMuteState.Enable.value
                }
            }
            return allow
        }

        fun convertConnectionState(connectionState: Int): ConnectionState {
            return when (connectionState) {
                CONNECTION_STATE_DISCONNECTED -> {
                    ConnectionState.DISCONNECTED
                }
                CONNECTION_STATE_DISCONNECTED -> {
                    ConnectionState.CONNECTING
                }
                CONNECTION_STATE_DISCONNECTED -> {
                    ConnectionState.CONNECTED
                }
                CONNECTION_STATE_DISCONNECTED -> {
                    ConnectionState.RECONNECTING
                }
                CONNECTION_STATE_DISCONNECTED -> {
                    ConnectionState.ABORTED
                }
                else -> {
                    ConnectionState.DISCONNECTED
                }
            }
        }

        fun convertConnectionStateChangeReason(changeReason: Int): ConnectionStateChangeReason {
            return when (changeReason) {
                CONNECTION_CHANGE_REASON_LOGIN -> {
                    ConnectionStateChangeReason.LOGIN
                }
                CONNECTION_CHANGE_REASON_LOGIN_SUCCESS -> {
                    ConnectionStateChangeReason.LOGIN_SUCCESS
                }
                CONNECTION_CHANGE_REASON_LOGIN_FAILURE -> {
                    ConnectionStateChangeReason.LOGIN_FAILURE
                }
                CONNECTION_CHANGE_REASON_LOGIN_TIMEOUT -> {
                    ConnectionStateChangeReason.LOGIN_TIMEOUT
                }
                CONNECTION_CHANGE_REASON_INTERRUPTED -> {
                    ConnectionStateChangeReason.INTERRUPTED
                }
                CONNECTION_CHANGE_REASON_LOGOUT -> {
                    ConnectionStateChangeReason.LOGOUT
                }
                CONNECTION_CHANGE_REASON_BANNED_BY_SERVER -> {
                    ConnectionStateChangeReason.BANNED_BY_SERVER
                }
                CONNECTION_CHANGE_REASON_REMOTE_LOGIN -> {
                    ConnectionStateChangeReason.REMOTE_LOGIN
                }
                else -> {
                    ConnectionStateChangeReason.LOGIN
                }
            }
        }

        fun convertCMDResponseBody(cmdResponseBody: CMDResponseBody<Any>): EduSequenceRes<Any> {
            return EduSequenceRes(cmdResponseBody.sequence, cmdResponseBody.cmd,
                    cmdResponseBody.version, cmdResponseBody.data)
        }

        fun convertEduSequenceRes(sequence: EduSequenceRes<Any>): CMDResponseBody<Any> {
            return CMDResponseBody(sequence.cmd, sequence.version, 0, null, sequence.sequence,
                    sequence.data)
        }

        fun convertUserInfo(userInfo: EduLocalUserInfo): EduUserInfoImpl {
            return EduUserInfoImpl(userInfo.userUuid, userInfo.userName, userInfo.role,
                    userInfo.isChatAllowed ?: false, (userInfo as EduLocalUserInfoImpl).updateTime)
        }

        fun streamExistsInList(streamInfo: EduStreamInfo, list: MutableList<EduStreamInfo>): Int {
            var pos = -1
            streamInfo?.let {
                for ((index, element) in list.withIndex()) {
                    if (element.same(it)) {
                        pos = index
                        break
                    }
                }
            }
            return pos
        }

        fun convertActionMsgType(value: Int): EduActionType {
            return when (value) {
                EduActionType.EduActionTypeApply.value -> {
                    EduActionType.EduActionTypeApply
                }
                EduActionType.EduActionTypeInvitation.value -> {
                    EduActionType.EduActionTypeApply
                }
                EduActionType.EduActionTypeAccept.value -> {
                    EduActionType.EduActionTypeApply
                }
                EduActionType.EduActionTypeReject.value -> {
                    EduActionType.EduActionTypeApply
                }
                else -> {
                    EduActionType.EduActionTypeReject
                }
            }
        }

        fun convertEduActionMsg(text: String): EduActionMessage {
            val cmdResponseBody = Gson().fromJson<CMDResponseBody<CMDActionMsgRes>>(text, object :
                    TypeToken<CMDResponseBody<CMDActionMsgRes>>() {}.type)
            val msg = cmdResponseBody.data
            return EduActionMessage(msg.processUuid,
                    convertActionMsgType(msg.action),
                    msg.fromRoom.roomUuid,
                    msg.fromUser,
                    msg.timeout,
                    msg.payload)
        }
    }
}
