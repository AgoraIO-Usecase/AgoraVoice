package io.agora.education.api.user.listener

import io.agora.education.api.stream.data.EduStreamEvent
import io.agora.education.api.stream.data.EduStreamInfo
import io.agora.education.api.user.data.EduUserEvent
import io.agora.education.api.user.data.EduUserInfo

interface EduUserEventListener {

    fun onLocalUserUpdated(userEvent: EduUserEvent)

    fun onLocalUserPropertyUpdated(userInfo: EduUserInfo, cause: MutableMap<String, Any>?)

    fun onLocalStreamAdded(streamEvent: EduStreamEvent)

    fun onLocalStreamUpdated(streamEvent: EduStreamEvent)

    fun onLocalStreamRemoved(streamEvent: EduStreamEvent)
}