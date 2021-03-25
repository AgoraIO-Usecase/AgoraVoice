package io.agora.agoravoice.business.definition.struct;

import io.agora.log.AgoraConsolePrintType;

public class Log {
    public static final int LOG_NONE = 1;
    public static final int LOG_INFO = 2;
    public static final int LOG_WARN = 3;
    public static final int LOG_ERROR = 4;

    public static int toBusinessLogLevel(int logLevel) {
        switch (logLevel) {
            case LOG_INFO: return AgoraConsolePrintType.INFO;
            case LOG_WARN: return AgoraConsolePrintType.WARNING;
            case LOG_ERROR: return AgoraConsolePrintType.ERROR;
            default: return AgoraConsolePrintType.NONE;
        }
    }
}
