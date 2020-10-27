package io.agora.education.api.manager

import android.util.Base64
import io.agora.education.api.EduCallback
import io.agora.education.api.logger.DebugItem
import io.agora.education.api.logger.LogLevel
import io.agora.education.api.manager.listener.EduManagerEventListener
import io.agora.education.api.room.EduRoom
import io.agora.education.api.room.data.EduLoginOptions
import io.agora.education.api.room.data.RoomCreateOptions
import io.agora.education.api.statistics.AgoraError
import io.agora.education.api.util.CryptoUtil.getAuth

abstract class EduManager(
        val options: EduManagerOptions
) {
    companion object {
        @JvmStatic
        fun init(options: EduManagerOptions): EduManager {
            return Class.forName("io.agora.education.impl.manager.EduManagerImpl")
                    .getConstructor(EduManagerOptions::class.java).newInstance(options) as EduManager
        }
    }

    var eduManagerEventListener: EduManagerEventListener? = null

//    abstract fun createClassroom(config: RoomCreateOptions, callback: EduCallback<EduRoom>)

    /**排课*/
    abstract fun scheduleClass(roomCreateOptions: RoomCreateOptions, callback: EduCallback<Unit>)

    /**登录rtm*/
    abstract fun login(loginOptions: EduLoginOptions, callback: EduCallback<Unit>)

    abstract fun logout()

    abstract fun release()

    abstract fun logMessage(message: String, level: LogLevel): AgoraError

    /**日志上传之后，会通过回调把serialNumber返回
     * serialNumber：日志序列号，可以用于查询日志*/
    abstract fun uploadDebugItem(item: DebugItem, callback: EduCallback<String>): AgoraError
}
