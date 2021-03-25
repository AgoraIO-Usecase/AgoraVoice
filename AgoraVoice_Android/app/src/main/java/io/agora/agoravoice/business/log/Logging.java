package io.agora.agoravoice.business.log;

import android.content.Context;

import io.agora.agoravoice.BuildConfig;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.UserUtil;
import io.agora.log.AgoraConsolePrintType;
import io.agora.log.AgoraLogManager;
import io.agora.log.AgoraLogType;

public class Logging {
    private static AgoraLogManager LOGGER;

    public static void init(Context context) {
        int type = BuildConfig.DEBUG ?
                AgoraConsolePrintType.ALL :
                AgoraConsolePrintType.INFO;
        try {
            LOGGER = new AgoraLogManager(
                    UserUtil.appLogFolderPath(context),
                    Const.LOG_PREFIX,
                    Const.LOG_MAX_FILES,
                    Const.LOG_TAG,
                    type);
        } catch (Exception e) {
            e.printStackTrace();
            LOGGER = null;
        }
    }

    public static void d(String message) {
        if (LOGGER != null) LOGGER.logMsg(message, AgoraLogType.DEBUG);
    }

    public static void i(String message) {
        if (LOGGER != null) LOGGER.logMsg(message, AgoraLogType.INFO);
    }

    public static void w(String message) {
        if (LOGGER != null) LOGGER.logMsg(message, AgoraLogType.WARNING);
    }

    public static void e(String message) {
        if (LOGGER != null) LOGGER.logMsg(message, AgoraLogType.ERROR);
    }

    public static void d(String message, Object ... args) {
        if (LOGGER != null) LOGGER.d(message, args);
    }

    public static void i(String message, Object ... args) {
        if (LOGGER != null) LOGGER.i(message, args);
    }

    public static void w(String message, Object ... args) {
        if (LOGGER != null) LOGGER.w(message, args);
    }

    public static  void e(String message, Object ... args) {
        if (LOGGER != null) LOGGER.e(message, args);
    }
}
