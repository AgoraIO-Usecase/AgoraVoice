package io.agora.education.api.room.listener

import io.agora.education.api.message.EduChatMsg
import io.agora.education.api.message.EduMsg
import io.agora.education.api.room.EduRoom
import io.agora.education.api.room.data.EduRoomStatus
import io.agora.education.api.room.data.RoomStatusEvent
import io.agora.education.api.statistics.ConnectionState
import io.agora.education.api.statistics.ConnectionStateChangeReason
import io.agora.education.api.statistics.NetworkQuality
import io.agora.education.api.stream.data.EduStreamEvent
import io.agora.education.api.stream.data.EduStreamInfo
import io.agora.education.api.user.data.EduUserEvent
import io.agora.education.api.user.data.EduUserInfo

interface EduRoomEventListener {

    fun onRemoteUsersInitialized(users: List<EduUserInfo>, classRoom: EduRoom)

    fun onRemoteUsersJoined(users: List<EduUserInfo>, classRoom: EduRoom)

    fun onRemoteUsersLeft(userEvents: MutableList<EduUserEvent>, classRoom: EduRoom)

    fun onRemoteUserUpdated(userEvents: MutableList<EduUserEvent>, classRoom: EduRoom)

    fun onRoomMessageReceived(message: EduMsg, classRoom: EduRoom)

    fun onRoomChatMessageReceived(chatMsg: EduChatMsg, classRoom: EduRoom)

    fun onRemoteStreamsInitialized(streams: List<EduStreamInfo>, classRoom: EduRoom)

    fun onRemoteStreamsAdded(streamEvents: MutableList<EduStreamEvent>, classRoom: EduRoom)

    fun onRemoteStreamsUpdated(streamEvents: MutableList<EduStreamEvent>, classRoom: EduRoom)

    fun onRemoteStreamsRemoved(streamEvents: MutableList<EduStreamEvent>, classRoom: EduRoom)

    fun onRoomStatusChanged(event: RoomStatusEvent, operatorUser: EduUserInfo?, classRoom: EduRoom)

    /**引起roomProperty发生改变的原因
     * 对应EduUser中的updateRoomProperty*/
    fun onRoomPropertyChanged(classRoom: EduRoom, cause: MutableMap<String, Any>?)

    /**引起userProperty发生改变的原因
     * 对应EduUser中的updateUserProperty*/
    fun onRemoteUserPropertiesUpdated(userInfos: MutableList<EduUserInfo>, classRoom: EduRoom, cause: MutableMap<String, Any>?)

    fun onNetworkQualityChanged(quality: NetworkQuality, user: EduUserInfo, classRoom: EduRoom)
}
