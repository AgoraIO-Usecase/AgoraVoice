package io.agora.agoravoice;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.ui.activities.SplashActivity;
import io.agora.agoravoice.utils.Const;

public class AgoraApplication extends Application {
    private ProxyManager mProxy;
    private Config mConfig;
    private SharedPreferences mPreferences;

    @Override
    public void onCreate() {
        super.onCreate();
        initGlobalVariables();
    }

    private void initGlobalVariables() {
        mPreferences = getSharedPreferences(Const.SP_NAME, Context.MODE_PRIVATE);
        mConfig = new Config();
        mProxy = new ProxyManager(this);
    }

    public ProxyManager proxy() {
        return mProxy;
    }

    public Config config() {
        return mConfig;
    }

    public SharedPreferences preferences() {
        return mPreferences;
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
        if (mProxy != null) mProxy.release();
    }
}
