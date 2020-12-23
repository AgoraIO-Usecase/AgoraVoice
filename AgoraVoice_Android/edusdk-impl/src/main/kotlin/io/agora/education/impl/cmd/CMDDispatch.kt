package io.agora.education.impl.cmd

import android.util.Log
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import io.agora.education.impl.util.Convert
import io.agora.education.api.manager.listener.EduManagerEventListener
import io.agora.education.api.message.EduChatMsg
import io.agora.education.api.room.EduRoom
import io.agora.education.api.room.data.Property
import io.agora.education.api.room.data.RoomStatusEvent
import io.agora.education.api.room.data.RoomType
import io.agora.education.api.stream.data.EduAudioState
import io.agora.education.api.user.data.EduChatState
import io.agora.education.api.user.data.EduUserEvent
import io.agora.education.impl.cmd.bean.*
import io.agora.education.impl.room.EduRoomImpl
import io.agora.education.impl.room.data.response.EduUserRes
import io.agora.rte.RteEngineImpl
import java.util.*

internal class CMDDispatch(private val eduRoom: EduRoom) {
    private val cmdCallbackManager: CMDCallbackManager = CMDCallbackManager()

    fun dispatchMsg(cmdResponseBody: CMDResponseBody<Any>?) {
        val text = Gson().toJson(cmdResponseBody)
        cmdResponseBody?.let {
            dispatchChannelMsg(text)
        }
    }

    fun dispatchChannelMsg(text: String) {
        val cmdResponseBody = Gson().fromJson<CMDResponseBody<Any>>(text, object :
                TypeToken<CMDResponseBody<Any>>() {}.type)
        when (cmdResponseBody.cmd) {
            CMDId.RoomStateChange.value -> {
                /**课堂状态发生改变*/
                val rtmRoomState = Gson().fromJson<CMDResponseBody<CMDRoomState>>(text, object :
                        TypeToken<CMDResponseBody<CMDRoomState>>() {}.type).data
                eduRoom.getRoomStatus().courseState = Convert.convertRoomState(rtmRoomState.state)
                eduRoom.getRoomStatus().startTime = rtmRoomState.startTime
                val roomType = (eduRoom as EduRoomImpl).getCurRoomType()

                // As because the non-null feature of kotlin language,
                // if the returned values from server are null, assign
                // them as an empty string
                val userRes = rtmRoomState.operator
                if (userRes.userName == null) userRes.userName = "";
                if (userRes.userUuid == null) userRes.userUuid = "";
                val operator = Convert.convertUserInfo(rtmRoomState.operator, roomType)
                cmdCallbackManager.onRoomStatusChanged(RoomStatusEvent.COURSE_STATE, operator, eduRoom)
            }
            CMDId.RoomMuteStateChange.value -> {
                val rtmRoomMuteState = Gson().fromJson<CMDResponseBody<CMDRoomMuteState>>(text, object :
                        TypeToken<CMDResponseBody<CMDRoomMuteState>>() {}.type).data
                when ((eduRoom as EduRoomImpl).getCurRoomType()) {
                    RoomType.ONE_ON_ONE, RoomType.SMALL_CLASS -> {
                        /**判断本次更改是否包含针对学生的全部禁聊;*/
                        val broadcasterMuteChat = rtmRoomMuteState.muteChat?.broadcaster
                        broadcasterMuteChat?.let {
                            eduRoom.getRoomStatus().isStudentChatAllowed =
                                    broadcasterMuteChat.toFloat().toInt() == EduChatState.Allow.value
                        }
                        /**
                         * roomStatus中仅定义了isStudentChatAllowed来标识是否全员禁聊；没有属性来标识是否全员禁摄像头和麦克风；
                         * 需要确定
                         * */
                    }
                    RoomType.LARGE_CLASS -> {
                        /**判断本次更改是否包含针对学生的全部禁聊;*/
                        val audienceMuteChat = rtmRoomMuteState.muteChat?.audience
                        audienceMuteChat?.let {
                            eduRoom.getRoomStatus().isStudentChatAllowed =
                                    audienceMuteChat.toFloat().toInt() == EduChatState.Allow.value
                        }
                    }
                }
                val operator = Convert.convertUserInfo(rtmRoomMuteState.operator, eduRoom.getCurRoomType())
                cmdCallbackManager.onRoomStatusChanged(RoomStatusEvent.STUDENT_CHAT, operator, eduRoom)
            }
            CMDId.RoomPropertyChanged.value -> {
                Log.e("CMDDispatch", "收到roomProperty改变的RTM:${text}")
                val properties = Gson().fromJson<CMDResponseBody<Map<String, Any>>>(text, object :
                        TypeToken<CMDResponseBody<Map<String, Any>>>() {}.type).data
                /**把变化的属性更新到本地*/
                eduRoom.roomProperties = properties
                val map = properties[Property.CAUSE]
                val cause: MutableMap<String, Any>? = map as MutableMap<String, Any>?
                /**通知用户房间属性发生改变*/
                Log.e("CMDDispatch", "把收到的roomProperty回调出去")
                cmdCallbackManager.onRoomPropertyChanged(eduRoom, cause)
            }
            CMDId.ChannelMsgReceived.value -> {
                /**频道内的聊天消息*/
                Log.e("CMDDispatch", "收到频道内聊天消息")
                val eduMsg = CMDUtil.buildEduMsg(text, eduRoom) as EduChatMsg
                Log.e("CMDDispatch", "构造出eduMsg")
                cmdCallbackManager.onRoomChatMessageReceived(eduMsg, eduRoom)
            }
            CMDId.ChannelCustomMsgReceived.value -> {
                /**频道内自定义消息(可以是用户的自定义的信令)*/
                val eduMsg = CMDUtil.buildEduMsg(text, eduRoom)
                cmdCallbackManager.onRoomMessageReceived(eduMsg, eduRoom)
            }
            CMDId.UserJoinOrLeave.value -> {
                val rtmInOutMsg = Gson().fromJson<CMDResponseBody<RtmUserInOutMsg>>(text, object :
                        TypeToken<CMDResponseBody<RtmUserInOutMsg>>() {}.type).data
                Log.e("CMDDispatch", "收到用户进入或离开的通知->${eduRoom.getRoomInfo().roomUuid}:${text}")
                /**根据回调数据，维护本地存储的流列表，并返回有效数据*/
                val validOnlineUsers = CMDDataMergeProcessor.addUserWithOnline(rtmInOutMsg.onlineUsers,
                        (eduRoom as EduRoomImpl).getCurUserList(), eduRoom.getCurRoomType())
                val validOfflineUsers = CMDDataMergeProcessor.removeUserWithOffline(rtmInOutMsg.offlineUsers,
                        eduRoom.getCurUserList(), eduRoom.getCurRoomType())

                /**判断是否携带了流信息*/
                val validAddedStreams = CMDDataMergeProcessor.addStreamWithUserOnline(rtmInOutMsg.onlineUsers,
                        eduRoom.getCurStreamList(), eduRoom.getCurRoomType())
                val validRemovedStreams = CMDDataMergeProcessor.removeStreamWithUserOffline(rtmInOutMsg.offlineUsers,
                        eduRoom.getCurStreamList(), eduRoom.getCurRoomType())
                /**人员进出会携带着各自可能存在的流信息*/
                if (validOnlineUsers.size > 0) {
                    cmdCallbackManager.onRemoteUsersJoined(validOnlineUsers, eduRoom)
                }
                if (validAddedStreams.size > 0) {
                    cmdCallbackManager.onRemoteStreamsAdded(validAddedStreams, eduRoom)
                }
                if (validOfflineUsers.size > 0) {
                    cmdCallbackManager.onRemoteUsersLeft(validOfflineUsers, eduRoom)
                }
                if (validRemovedStreams.size > 0) {
                    cmdCallbackManager.onRemoteStreamsRemoved(validRemovedStreams, eduRoom)
                }
            }
            CMDId.UserStateChange.value -> {
                val cmdUserStateMsg = Gson().fromJson<CMDResponseBody<CMDUserStateMsg>>(text, object :
                        TypeToken<CMDResponseBody<CMDUserStateMsg>>() {}.type).data
                val validUserList = CMDDataMergeProcessor.updateUserWithUserStateChange(cmdUserStateMsg,
                        (eduRoom as EduRoomImpl).getCurUserList(), eduRoom.getCurRoomType())
                cmdCallbackManager.onRemoteUserUpdated(validUserList, eduRoom)
                /**判断有效的数据中是否有本地用户的数据,有则处理并回调*/
                for (element in validUserList) {
                    if (element.modifiedUser.userUuid == eduRoom.getLocalUser().userInfo.userUuid) {
                        cmdCallbackManager.onLocalUserUpdated(EduUserEvent(element.modifiedUser,
                                element.operatorUser), eduRoom.getLocalUser())
                    }
                }
            }
            CMDId.UserPropertiedChanged.value -> {
                Log.e("CMDDispatch", "收到userProperty改变的通知:${text}")
                val cmdUserPropertyRes = Gson().fromJson<CMDResponseBody<CMDUserPropertyRes>>(text, object :
                        TypeToken<CMDResponseBody<CMDUserPropertyRes>>() {}.type).data
                val updatedUserInfo = CMDDataMergeProcessor.updateUserPropertyWithChange(cmdUserPropertyRes,
                        (eduRoom as EduRoomImpl).getCurUserList())
                updatedUserInfo?.let {
                    if (updatedUserInfo == eduRoom.getLocalUser().userInfo) {
                        cmdCallbackManager.onLocalUserPropertyUpdated(it, cmdUserPropertyRes.cause,
                                eduRoom.getLocalUser())
                    } else {
                        /**远端用户property发生改变如何回调出去*/
                        val userInfos = Collections.singletonList(updatedUserInfo)
                        cmdCallbackManager.onRemoteUserPropertiesUpdated(userInfos, eduRoom,
                                cmdUserPropertyRes.cause)
                    }
                }
            }
            CMDId.StreamStateChange.value -> {
                val cmdStreamActionMsg = Gson().fromJson<CMDResponseBody<CMDStreamActionMsg>>(text, object :
                        TypeToken<CMDResponseBody<CMDStreamActionMsg>>() {}.type).data
                /**根据回调数据，维护本地存储的流列表*/
                when (cmdStreamActionMsg.action) {
                    /**流的Add和Remove跟随人员进出,所以此处的Add和Remove不会走了*/
                    CMDStreamAction.Add.value -> {
                        Log.e("CMDDispatch", "收到新添加流的通知：${text}")
                        val validAddStreams = CMDDataMergeProcessor.addStreamWithAction(cmdStreamActionMsg,
                                (eduRoom as EduRoomImpl).getCurStreamList(), eduRoom.getCurRoomType())
                        Log.e("CMDDispatch", "有效新添加流大小：" + validAddStreams.size)
                        /**判断有效的数据中是否有本地流的数据,有则处理并回调*/
                        val iterable = validAddStreams.iterator()
                        while (iterable.hasNext()) {
                            val element = iterable.next()
                            val streamInfo = element.modifiedStream
                            if (streamInfo.publisher == eduRoom.getLocalUser().userInfo) {
                                RteEngineImpl.updateLocalStream(streamInfo.hasAudio, streamInfo.hasVideo)
                                Log.e("CMDDispatch", "join成功，把新添加的本地流回调出去")
                                cmdCallbackManager.onLocalStreamAdded(element, eduRoom.getLocalUser())
                                iterable.remove()
                            }
                        }
                        if (validAddStreams.size > 0) {
                            Log.e("CMDDispatch", "join成功，把新添加远端流回调出去")
                            cmdCallbackManager.onRemoteStreamsAdded(validAddStreams, eduRoom)
                        }
                    }
                    CMDStreamAction.Modify.value -> {
                        Log.e("CMDDispatch", "收到修改流的通知：${text}")
                        val validModifyStreams = CMDDataMergeProcessor.updateStreamWithAction(cmdStreamActionMsg,
                                (eduRoom as EduRoomImpl).getCurStreamList(), (eduRoom as EduRoomImpl).getCurRoomType())
                        Log.e("CMDDispatch", "有效修改流大小：" + validModifyStreams.size)
                        /**判断有效的数据中是否有本地流的数据,有则处理并回调*/
                        val iterable = validModifyStreams.iterator()
                        while (iterable.hasNext()) {
                            val element = iterable.next()
                            if (element.modifiedStream.publisher == eduRoom.getLocalUser().userInfo) {
                                RteEngineImpl.updateLocalStream(element.modifiedStream.hasAudio,
                                        element.modifiedStream.hasVideo)
                                Log.e("CMDDispatch", "join成功，把发生改变的本地流回调出去")
                                cmdCallbackManager.onLocalStreamUpdated(element, eduRoom.getLocalUser())
                                iterable.remove()
                            }
                        }
                        if (validModifyStreams.size > 0) {
                            Log.e("CMDDispatch", "join成功，把发生改变的远端流回调出去")
                            cmdCallbackManager.onRemoteStreamsUpdated(validModifyStreams, eduRoom)
                        }
                    }
                    CMDStreamAction.Remove.value -> {
                        Log.e("CMDDispatch", "收到移除流的通知：${text}")
                        val validRemoveStreams = CMDDataMergeProcessor.removeStreamWithAction(cmdStreamActionMsg,
                                (eduRoom as EduRoomImpl).getCurStreamList(), eduRoom.getCurRoomType())

                        /**判断有效的数据中是否有本地流的数据,有则处理并回调*/
                        val iterable = validRemoveStreams.iterator()
                        while (iterable.hasNext()) {
                            val element = iterable.next()
                            if (element.modifiedStream.publisher == eduRoom.getLocalUser().userInfo) {
                                RteEngineImpl.updateLocalStream(element.modifiedStream.hasAudio,
                                        element.modifiedStream.hasVideo)
                                cmdCallbackManager.onLocalStreamRemoved(element, eduRoom.getLocalUser())
                                iterable.remove()
                            }
                        }
                        if (validRemoveStreams.size > 0) {
                            Log.e("CMDDispatch", "join成功，把被移除的远端流回调出去")
                            cmdCallbackManager.onRemoteStreamsRemoved(validRemoveStreams, eduRoom)
                        }
                    }
                }
            }
            CMDId.BoardRoomStateChange.value -> {
            }
            CMDId.BoardUserStateChange.value -> {
            }
        }
    }

    fun dispatchPeerMsg(text: String, listener: EduManagerEventListener?) {
        val cmdResponseBody = Gson().fromJson<CMDResponseBody<Any>>(text, object :
                TypeToken<CMDResponseBody<Any>>() {}.type)
        when (cmdResponseBody.cmd) {
            CMDId.PeerMsgReceived.value -> {
                /**点对点的聊天消息*/
                val eduMsg = CMDUtil.buildEduMsg(text, eduRoom) as EduChatMsg
                cmdCallbackManager.onUserChatMessageReceived(eduMsg, listener)
            }
            CMDId.ActionMsgReceived.value -> {
                /**邀请申请动作消息*/
                val actionMsg = Convert.convertEduActionMsg(text)
                cmdCallbackManager.onUserActionMessageReceived(actionMsg, listener)
            }
            CMDId.PeerCustomMsgReceived.value -> {
                /**点对点的自定义消息(可以是用户自定义的信令)*/
                val eduMsg = CMDUtil.buildEduMsg(text, eduRoom)
                cmdCallbackManager.onUserMessageReceived(eduMsg, listener)
            }
//            /**只要发起数据同步请求就会受到此消息*/
//            CMDId.SyncRoomInfo.value -> {
//                Log.e("CMDDispatch", "收到同步房间信息的消息:" + text)
//                /**接收到需要同步的房间信息*/
//                val cmdSyncRoomInfoRes = Gson().fromJson<CMDResponseBody<CMDSyncRoomInfoRes>>(text,
//                        object : TypeToken<CMDResponseBody<CMDSyncRoomInfoRes>>() {}.type)
//                /**数据同步流程中需要根据requestId判断，此次接收到的数据是否对应于当前请求*/
//                if (cmdResponseBody.requestId == (eduRoom as EduRoomImpl).roomSyncHelper.getCurRequestId()) {
//                    val event = CMDDataMergeProcessor.syncRoomInfoToEduRoom(cmdSyncRoomInfoRes.data, eduRoom)
//                    synchronized(eduRoom.joinSuccess) {
//                        /**在join成功之后同步数据过程中，如果教室数据发生改变就回调出去*/
//                        if (eduRoom.joinSuccess && event != null) {
//                            cmdCallbackManager.onRoomStatusChanged(event, null, eduRoom)
//                        }
//                    }
//                    /**roomInfo同步完成，打开开关*/
//                    roomStateChangeEnable = true
//                    /**roomInfo同步成功*/
//                    Log.e("CMDDispatch", "房间信息同步完成")
//                    eduRoom.syncRoomOrAllUserStreamSuccess(
//                            true, null, null)
//                }
//            }
//            /**同步人流数据的消息*/
//            CMDId.SyncUsrStreamList.value -> {
//                /**接收到需要同步的人流信息*/
//                val cmdSyncUserStreamRes = Gson().fromJson<CMDResponseBody<CMDSyncUserStreamRes>>(text,
//                        object : TypeToken<CMDResponseBody<CMDSyncUserStreamRes>>() {}.type)
//                /**数据同步流程中需要根据requestId判断，此次接收到的数据是否对应于当前请求*/
//                if (cmdResponseBody.requestId == (eduRoom as EduRoomImpl).roomSyncHelper.getCurRequestId()) {
//                    val syncUserStreamData: CMDSyncUserStreamRes = cmdSyncUserStreamRes.data
//                    /**第一阶段（属于join流程）（根据nextId全量），如果中间断连，可根据nextId续传;
//                     * 第二阶段（不属于join流程）（根据ts增量），如果中间断连，可根据ts续传*/
//                    when (syncUserStreamData.step) {
//                        EduSyncStep.FIRST.value -> {
//                            Log.e("CMDDispatch", "收到同步人流的消息-第一阶段:" + text)
//                            /**把此部分的全量人流数据同步到本地缓存中*/
//                            CMDDataMergeProcessor.syncUserStreamListToEduRoomWithFirst(syncUserStreamData, eduRoom)
//                            val firstFinished = syncUserStreamData.isFinished == EduSyncFinished.YES.value
//                            /**接收到一部分全量数据，就调用一次，目的是为了刷新rtm超时任务*/
//                            eduRoom.syncRoomOrAllUserStreamSuccess(null,
//                                    firstFinished, null)
//                            /**更新全局的nextId,方便在后续出现异常的时候可以以当前节点为起始步骤继续同步*/
//                            eduRoom.roomSyncHelper.updateNextId(syncUserStreamData.nextId)
//                            /**如果步骤一同步完成，则说明join流程中的同步全量人流数据阶段完成，同时还需要把全局的step改为2，
//                             * 防止在步骤二(join流程中的同步增量人流数据阶段)过程出现异常后，再次发起的同步请求中step还是1*/
//                            if (firstFinished) {
//                                Log.e("CMDDispatch", "收到同步人流的消息-第一阶段完成")
//                                eduRoom.roomSyncHelper.updateStep(EduSyncStep.SECOND.value)
//                            }
//                        }
//                        EduSyncStep.SECOND.value -> {
//                            Log.e("CMDDispatch", "收到同步人流的消息-第二阶段:" + text)
//                            /**增量数据合并到本地缓存中去*/
//                            val validDatas = CMDDataMergeProcessor.syncUserStreamListToEduRoomWithSecond(
//                                    syncUserStreamData, eduRoom)
//                            val incrementFinished = syncUserStreamData.isFinished == EduSyncFinished.YES.value
//                            synchronized(eduRoom.joinSuccess) {
//                                /**接收到一部分增量数据，就调用一次，目的是为了刷新rtm超时任务*/
//                                if (eduRoom.joinSuccess) {
//                                    Log.e("CMDDispatch", "收到同步人流的消息-join成功后的增量")
//                                    eduRoom.roomSyncHelper.interruptRtmTimeout(!incrementFinished)
//                                } else {
//                                    if (incrementFinished) {
//                                        Log.e("CMDDispatch", "收到同步人流的消息-第二阶段完成")
//                                        (eduRoom as EduRoomImpl).syncRoomOrAllUserStreamSuccess(
//                                                null, null, incrementFinished)
//                                    }
//                                }
//                                /**更新全局的nextTs,方便在后续出现异常的时候可以以当前节点为起始步骤继续同步*/
//                                eduRoom.roomSyncHelper.updateNextTs(syncUserStreamData.nextTs)
//                                /**获取有效的增量数据*/
//                                if (eduRoom.joinSuccess) {
//                                    eduRoom.dataCache.addValidDataBySyncing(validDatas)
//                                }
//                                if (incrementFinished) {
//                                    /**成功加入房间后的全部增量数据需要回调出去*/
//                                    if (eduRoom.joinSuccess) {
//                                        Log.e("CMDDispatch", "收到同步人流的消息-join成功后的增量-完成")
//                                        cmdCallbackManager.callbackValidData(eduRoom)
//                                    }
//                                    /**userStream同步完成，打开开关*/
//                                    userStreamChangeEnable = true
//                                }
//                            }
//                        }
//                    }
//                }
//            }
        }
    }

}