package io.agora.education.api.statistics

enum class ConnectionState(var value: Int) {
    DISCONNECTED(1),
    CONNECTING(2),
    CONNECTED(3),
    RECONNECTING(4),
    ABORTED(5)
}

enum class ConnectionStateChangeReason(var value: Int) {
    LOGIN(1),
    LOGIN_SUCCESS(2),
    LOGIN_FAILURE(3),
    LOGIN_TIMEOUT(4),
    INTERRUPTED(5),
    LOGOUT(6),
    BANNED_BY_SERVER(7),
    REMOTE_LOGIN(8),
}
