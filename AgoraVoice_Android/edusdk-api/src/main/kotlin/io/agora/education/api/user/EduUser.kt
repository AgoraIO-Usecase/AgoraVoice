package io.agora.education.api.user

import android.view.ViewGroup
import io.agora.education.api.EduCallback
import io.agora.education.api.message.EduChatMsg
import io.agora.education.api.message.EduMsg
import io.agora.education.api.stream.data.*
import io.agora.education.api.user.data.EduLocalUserInfo
import io.agora.education.api.user.data.EduStartActionConfig
import io.agora.education.api.user.data.EduStopActionConfig
import io.agora.education.api.user.data.EduUserInfo
import io.agora.education.api.user.listener.EduUserEventListener

interface EduUser {
    var userInfo: EduLocalUserInfo
    var videoEncoderConfig: VideoEncoderConfig

    var eventListener: EduUserEventListener?

    fun initOrUpdateLocalStream(options: LocalStreamInitOptions, callback: EduCallback<EduStreamInfo>)

    fun switchCamera()

    fun subscribeStream(stream: EduStreamInfo, options: StreamSubscribeOptions)

    fun unSubscribeStream(stream: EduStreamInfo)

    fun publishStream(stream: EduStreamInfo, callback: EduCallback<Boolean>)

    fun unPublishStream(stream: EduStreamInfo, callback: EduCallback<Boolean>)

    /**发送自定义消息*/
    fun sendRoomMessage(message: String, callback: EduCallback<EduMsg>)

    /**
     * @param user 消息接收方的userInfo*/
    fun sendUserMessage(message: String, user: EduUserInfo, callback: EduCallback<EduMsg>)

    /**发送聊天消息*/
    fun sendRoomChatMessage(message: String, callback: EduCallback<EduChatMsg>)

    fun sendUserChatMessage(message: String, remoteUser: EduUserInfo, callback: EduCallback<EduChatMsg>)

    /*process action
    * 一期教育SDK没有这个方法，只是给娱乐使用*/
    fun startActionWithConfig(config: EduStartActionConfig, callback: EduCallback<Unit>)
    fun stopActionWithConfig(config: EduStopActionConfig, callback: EduCallback<Unit>)

    fun setStreamView(stream: EduStreamInfo, channelId: String, viewGroup: ViewGroup?, config: VideoRenderConfig = VideoRenderConfig())

    fun setStreamView(stream: EduStreamInfo, channelId: String, viewGroup: ViewGroup?)

    fun updateRoomProperty(property: MutableMap.MutableEntry<String, String>,
                           cause: MutableMap<String, String>, callback: EduCallback<Unit>)

    fun updateUserProperty(property: MutableMap.MutableEntry<String, String>,
                           cause: MutableMap<String, String>, targetUser: EduUserInfo, callback: EduCallback<Unit>)
}
