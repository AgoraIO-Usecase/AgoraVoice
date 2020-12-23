package io.agora.education.impl.room.data.request


internal class RoomCreateOptionsReq constructor() {
    lateinit var roomName: String
    lateinit var roleConfig: RoleConfig

    constructor(roomName: String, roleConfig: RoleConfig) : this() {
        this.roomName = roomName
        this.roleConfig = roleConfig
    }
}

internal class RoleConfig constructor() {
    lateinit var host: LimitConfig
    lateinit var broadcaster: LimitConfig
    lateinit var audience: LimitConfig
    lateinit var assistant: LimitConfig

    constructor(host: LimitConfig, broadcaster: LimitConfig, audience: LimitConfig, assistant: LimitConfig)
            : this() {
    }
}

internal class LimitConfig constructor(val limit: Int) {
    var verifyType = VerifyType.Allow.value

    constructor(limit: Int, verifyType: Int) : this(limit) {
        this.verifyType = verifyType
    }
}

/**验证类型, 0: 允许匿名, 1: 不允许匿名 */
internal enum class VerifyType(var value: Int) {
    Allow(0),
    NotAllow(1)
}