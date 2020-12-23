package io.agora

import io.agora.log.LogManager

internal class Constants {
    companion object {
        const val API_BASE_URL_DEV = "https://api-solutions-dev.sh.agoralab.co";
        const val API_BASE_URL_PRODUCT = "https://api.agora.io";
        lateinit var APPID: String
        lateinit var API_BASE_URL: String
        lateinit var AgoraLog: LogManager
        const val LOGS_DIR_NAME = "logs"
        const val LOG_APPSECRET = "7AIsPeMJgQAppO0Z";
    }
}