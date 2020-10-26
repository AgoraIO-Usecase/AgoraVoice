package io.agora.education.api.room.data

import io.agora.education.api.user.data.EduUserRole
import io.agora.rte.data.RteChannelMediaOptions

data class RoomMediaOptions(
        var autoSubscribe: Boolean = true,
        var publishType: AutoPublishItem = AutoPublishItem.NoOperation
) {
    /**用户传了primaryStreamId,那么就用他当做streamUuid;如果没传，就是默认值，后端会生成一个streamUuid*/
    var primaryStreamId: Int = DefaultStreamId

    companion object {
        const val DefaultStreamId = 0
    }

    constructor(primaryStreamId: Int) : this() {
        this.primaryStreamId = primaryStreamId
    }

    fun isAutoPublish(): Boolean {
        return this.publishType == AutoPublishItem.AutoPublish
    }

    fun isAutoSubscribe(): Boolean {
        return this.autoSubscribe
    }

    fun convert(): RteChannelMediaOptions {
        return RteChannelMediaOptions(autoSubscribe, autoSubscribe)
    }
}

data class RoomJoinOptions(
        val userUuid: String,
        val userName: String,
        val roleType: EduUserRole,
        val mediaOptions: RoomMediaOptions
) {
    fun closeAutoPublish() {
        mediaOptions.publishType = AutoPublishItem.NoAutoPublish
    }
}

enum class AutoPublishItem(val value: Int) {
    NoOperation(0),
    AutoPublish(1),
    NoAutoPublish(2)
}
