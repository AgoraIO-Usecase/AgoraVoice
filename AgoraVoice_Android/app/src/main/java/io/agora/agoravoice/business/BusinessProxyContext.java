package io.agora.agoravoice.business;

import android.content.Context;

import androidx.annotation.NonNull;

public class BusinessProxyContext {
    private Context mContext;
    private String mAppId;
    private String mCustomerId;
    private String mCertificate;
    private String mUserId;
    private int mLogLevel;
    private String mLogFile;

    public Context getContext() {
        return mContext;
    }

    public String getAppId() {
        return mAppId;
    }

    public String getCustomerId() {
        return mCustomerId;
    }

    public String getCertificate() {
        return mCertificate;
    }

    public int getLogLevel() {
        return mLogLevel;
    }

    public String getLogFile() {
        return mLogFile;
    }

    public String getUserId() {
        return mUserId;
    }

    public BusinessProxyContext(@NonNull Context context, @NonNull String appId,
                                @NonNull String customerId, String certificate,
                                String logFile, int logLevel) {
        mContext = context;
        mAppId = appId;
        mCustomerId = customerId;
        mCertificate = certificate;
        mLogFile = logFile;
        mLogLevel = logLevel;
    }

    public BusinessProxyContext(@NonNull Context context,
                                @NonNull String appId,
                                @NonNull String customerId,
                                @NonNull String certificate) {
        mContext = context;
        mAppId = appId;
        mCustomerId = customerId;
        mCertificate = certificate;
    }
}
