package io.agora.agoravoice;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Log;

import com.elvishew.xlog.LogConfiguration;
import com.elvishew.xlog.LogLevel;
import com.elvishew.xlog.XLog;
import com.elvishew.xlog.flattener.PatternFlattener;
import com.elvishew.xlog.formatter.message.json.DefaultJsonFormatter;
import com.elvishew.xlog.formatter.message.throwable.DefaultThrowableFormatter;
import com.elvishew.xlog.formatter.message.xml.DefaultXmlFormatter;
import com.elvishew.xlog.formatter.stacktrace.DefaultStackTraceFormatter;
import com.elvishew.xlog.formatter.thread.DefaultThreadFormatter;
import com.elvishew.xlog.printer.AndroidPrinter;
import com.elvishew.xlog.printer.Printer;
import com.elvishew.xlog.printer.file.FilePrinter;
import com.elvishew.xlog.printer.file.backup.FileSizeBackupStrategy;
import com.elvishew.xlog.printer.file.clean.FileLastModifiedCleanStrategy;
import com.elvishew.xlog.printer.file.naming.DateFileNameGenerator;

import java.util.List;

import io.agora.agoravoice.business.definition.struct.AppVersionInfo;
import io.agora.agoravoice.business.definition.struct.GiftInfo;
import io.agora.agoravoice.business.definition.struct.MusicInfo;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.RandomUtil;
import io.agora.agoravoice.utils.UserUtil;

public class AgoraVoiceApplication extends Application {
    private ProxyManager mProxy;
    private GlobalListener mGlobalListener;
    private Config mConfig;
    private SharedPreferences mPreferences;

    private class GlobalListener implements ProxyManager.GeneralServiceListener,
            ProxyManager.UserServiceListener {
        @Override
        public void onCheckVersionSuccess(AppVersionInfo info) {

        }

        @Override
        public void onMusicList(List<MusicInfo> info) {
            config().updateMusicInfo(info);
        }

        @Override
        public void onGiftList(List<GiftInfo> info) {
            config().updateGiftInfo(info);
        }

        @Override
        public void onGeneralServiceFailed(int type, int code, String message) {

        }

        @Override
        public void onUserCreated(String userId, String userName) {
            Log.i("agora voice application", "onUserCreated " + userId);
            config().setUserId(userId);
            config().setNickname(userName);
            preferences().edit().putString(Const.KEY_USER_ID, userId).apply();
            preferences().edit().putString(Const.KEY_USER_NAME, userName).apply();
            login();
        }

        @Override
        public void onEditUser(String userId, String userName) {

        }

        @Override
        public void onLoginSuccess(String userId, String userToken, String rtmToken) {
            Log.i("agora voice application", "onLoginSuccess " + userToken);
            config().setUserToken(userToken);
            config().setRtmToken(rtmToken);
        }

        @Override
        public void onUserServiceFailed(int type, int code, String message) {

        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        init();
    }

    private void init() {
        initXLog();

        mProxy = new ProxyManager(getApplicationContext());
        mGlobalListener = new GlobalListener();
        mProxy.addGeneralServiceListener(mGlobalListener);
        mProxy.addUserServiceListener(mGlobalListener);

        mConfig = new Config();
        mPreferences = getSharedPreferences(Const.SP_NAME, Context.MODE_PRIVATE);
        initUserFromStorage();
        getMusicList();
        login();
    }

    private void initXLog() {
        LogConfiguration config = new LogConfiguration.Builder()
                .logLevel(BuildConfig.DEBUG ?
                        LogLevel.DEBUG : LogLevel.INFO)                         // Specify log level, logs below this level won't be printed, default: LogLevel.ALL
                .tag("AgoraVoice")                                               // Specify TAG, default: "X-LOG"
                //.t()                                                            // Enable thread info, disabled by default
                .st(Const.LOG_CLASS_DEPTH)                           // Enable stack trace info with depth 2, disabled by default
                // .b()                                                            // Enable border, disabled by default
                .jsonFormatter(new DefaultJsonFormatter())                      // Default: DefaultJsonFormatter
                .xmlFormatter(new DefaultXmlFormatter())                        // Default: DefaultXmlFormatter
                .throwableFormatter(new DefaultThrowableFormatter())            // Default: DefaultThrowableFormatter
                .threadFormatter(new DefaultThreadFormatter())                  // Default: DefaultThreadFormatter
                .stackTraceFormatter(new DefaultStackTraceFormatter())          // Default: DefaultStackTraceFormatter
                .build();

        Printer androidPrinter = new AndroidPrinter();                          // Printer that print the log using android.util.Log

        String flatPattern = "{d yy/MM/dd HH:mm:ss} {l}|{t}: {m}";
        Printer filePrinter = new FilePrinter                                   // Printer that print the log to the file system
                .Builder(UserUtil.appLogFolderPath(this))               // Specify the path to save log file
                .fileNameGenerator(new DateFileNameGenerator())                 // Default: ChangelessFileNameGenerator("log")
                .backupStrategy(new FileSizeBackupStrategy(
                        Const.APP_LOG_SIZE))                                    // Default: FileSizeBackupStrategy(1024 * 1024)
                .cleanStrategy(new FileLastModifiedCleanStrategy(
                        Const.LOG_DURATION))
                .flattener(new PatternFlattener(flatPattern))                   // Default: DefaultFlattener
                .build();

        XLog.init(                                                              // Initialize XLog
                config,                                                         // Specify the log configuration, if not specified, will use new LogConfiguration.Builder().build()
                androidPrinter,
                filePrinter);
    }

    private void initUserFromStorage() {
        config().setUserId(preferences().getString(Const.KEY_USER_ID, null));
        config().setNickname(preferences().getString(Const.KEY_USER_NAME, null));
        config().setUserToken(preferences().getString(Const.KEY_TOKEN, null));
    }

    private void getMusicList() {
        proxy().getMusicList();
    }

    private void login() {
        selectRandomNameIfNotExist();
        if (!config().isUserExisted()) {
            proxy().createUser(config().getNickname());
        } else {
            proxy().login(config().getUserId());
        }
    }

    private void selectRandomNameIfNotExist() {
        if (TextUtils.isEmpty(config().getNickname())) {
            config().setNickname(RandomUtil.randomUserName(this));
        }
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
        mProxy.release();
    }
}
