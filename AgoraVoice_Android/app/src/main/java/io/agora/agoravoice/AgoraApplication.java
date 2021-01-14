package io.agora.agoravoice;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;

import com.tencent.bugly.crashreport.CrashReport;

import io.agora.agoravoice.business.log.Logging;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.utils.Const;

public class AgoraApplication extends Application {
    private ProxyManager mProxy;
    private Config mConfig;
    private SharedPreferences mPreferences;

    @Override
    public void onCreate() {
        super.onCreate();
        // Log must be initialized before 
        // all other functions
        Logging.init(this);
        initGlobalVariables();
        initBugly();
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

    private void initBugly() {
        CrashReport.initCrashReport(getApplicationContext(),
                getResources().getString(R.string.bugly_app_id), false);
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
        if (mProxy != null) mProxy.release();
    }
}
