package io.agora.education.impl.cmd.bean

import io.agora.education.api.user.data.EduBaseUserInfo

class CMDUserPropertyRes(
        val fromUser: EduBaseUserInfo,
        val userProperties: Map<String, Any>,
        val cause: MutableMap<String, Any>?
) {
}