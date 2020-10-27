package io.agora.agoravoice.business.definition.struct;

import io.agora.education.api.logger.LogLevel;

public class Log {
    public static final int LOG_NONE = 1;
    public static final int LOG_INFO = 2;
    public static final int LOG_WARN = 3;
    public static final int LOG_ERROR = 4;

    public static LogLevel toBusinessLogLevel(int logLevel) {
        switch (logLevel) {
            case LOG_INFO: return LogLevel.INFO;
            case LOG_WARN: return LogLevel.WARN;
            case LOG_ERROR: return LogLevel.ERROR;
            default: return LogLevel.NONE;
        }
    }
}
