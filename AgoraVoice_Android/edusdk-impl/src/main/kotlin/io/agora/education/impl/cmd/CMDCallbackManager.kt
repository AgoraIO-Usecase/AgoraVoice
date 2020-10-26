package io.agora.education.impl.cmd

import io.agora.education.api.manager.listener.EduManagerEventListener
import io.agora.education.api.message.EduActionMessage
import io.agora.education.api.message.EduChatMsg
import io.agora.education.api.message.EduMsg
import io.agora.education.api.room.EduRoom
import io.agora.education.api.room.data.RoomStatusEvent
import io.agora.education.api.stream.data.EduStreamEvent
import io.agora.education.api.user.EduUser
import io.agora.education.api.user.data.EduUserEvent
import io.agora.education.api.user.data.EduUserInfo
import io.agora.education.impl.cmd.bean.CMDActionMsgRes
import io.agora.education.impl.cmd.bean.CMDStreamActionMsg

internal class CMDCallbackManager {

    fun onRoomStatusChanged(event: RoomStatusEvent, operatorUser: EduUserInfo?, classRoom: EduRoom) {
        classRoom.eventListener?.onRoomStatusChanged(event, operatorUser, classRoom)
    }

    fun onRoomPropertyChanged(classRoom: EduRoom, cause: MutableMap<String, Any>?) {
        classRoom.eventListener?.onRoomPropertyChanged(classRoom, cause)
    }

    fun onRoomChatMessageReceived(chatMsg: EduChatMsg, classRoom: EduRoom) {
        classRoom.eventListener?.onRoomChatMessageReceived(chatMsg, classRoom)
    }

    fun onRoomMessageReceived(message: EduMsg, classRoom: EduRoom) {
        classRoom.eventListener?.onRoomMessageReceived(message, classRoom)
    }

    fun onRemoteUsersJoined(users: List<EduUserInfo>, classRoom: EduRoom) {
        classRoom.eventListener?.onRemoteUsersJoined(users, classRoom)
    }

    fun onRemoteStreamsAdded(streamEvents: MutableList<EduStreamEvent>, classRoom: EduRoom) {
        classRoom.eventListener?.onRemoteStreamsAdded(streamEvents, classRoom)
    }

    fun onRemoteUsersLeft(userEvents: MutableList<EduUserEvent>, classRoom: EduRoom) {
        classRoom.eventListener?.onRemoteUsersLeft(userEvents, classRoom)
    }

    fun onRemoteStreamsRemoved(streamEvents: MutableList<EduStreamEvent>, classRoom: EduRoom) {
        classRoom.eventListener?.onRemoteStreamsRemoved(streamEvents, classRoom)
    }

    fun onRemoteUserPropertiesUpdated(userInfos: MutableList<EduUserInfo>, classRoom: EduRoom,
                                      cause: MutableMap<String, Any>?) {
        classRoom.eventListener?.onRemoteUserPropertiesUpdated(userInfos, classRoom, cause)
    }

    fun onRemoteStreamsUpdated(streamEvents: MutableList<EduStreamEvent>, classRoom: EduRoom) {
        classRoom.eventListener?.onRemoteStreamsUpdated(streamEvents, classRoom)
    }

    fun onRemoteUserUpdated(userEvents: MutableList<EduUserEvent>, classRoom: EduRoom) {
        classRoom.eventListener?.onRemoteUserUpdated(userEvents, classRoom)
    }

    fun onLocalUserUpdated(userEvent: EduUserEvent, eduUser: EduUser) {
        eduUser.eventListener?.onLocalUserUpdated(userEvent)
    }

    fun onLocalUserPropertyUpdated(userInfo: EduUserInfo, cause: MutableMap<String, Any>?, eduUser: EduUser) {
        eduUser.eventListener?.onLocalUserPropertyUpdated(userInfo, cause)
    }

    fun onLocalStreamAdded(streamEvent: EduStreamEvent, eduUser: EduUser) {
        eduUser.eventListener?.onLocalStreamAdded(streamEvent)
    }

    fun onLocalStreamUpdated(streamEvent: EduStreamEvent, eduUser: EduUser) {
        eduUser.eventListener?.onLocalStreamUpdated(streamEvent)
    }

    fun onLocalStreamRemoved(streamEvent: EduStreamEvent, eduUser: EduUser) {
        eduUser.eventListener?.onLocalStreamRemoved(streamEvent)
    }


    fun onUserChatMessageReceived(chatMsg: EduChatMsg, listener: EduManagerEventListener?) {
        listener?.onUserChatMessageReceived(chatMsg)
    }

    fun onUserMessageReceived(message: EduMsg, listener: EduManagerEventListener?) {
        listener?.onUserMessageReceived(message)
    }

    fun onUserActionMessageReceived(actionMsg: EduActionMessage, listener: EduManagerEventListener?) {
        listener?.onUserActionMessageReceived(actionMsg)
    }
}