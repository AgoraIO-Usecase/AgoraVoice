package io.agora.agoravoice.ui.activities;

import android.app.Dialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.widget.RelativeLayout;
import android.widget.Toast;

import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;

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

import io.agora.agoravoice.BuildConfig;
import io.agora.agoravoice.R;
import io.agora.agoravoice.business.definition.struct.AppVersionInfo;
import io.agora.agoravoice.business.definition.struct.BusinessType;
import io.agora.agoravoice.business.definition.struct.GiftInfo;
import io.agora.agoravoice.business.definition.struct.MusicInfo;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.ui.activities.main.MainActivity;
import io.agora.agoravoice.ui.views.CropBackgroundRelativeLayout;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.DialogUtil;
import io.agora.agoravoice.utils.RandomUtil;
import io.agora.agoravoice.utils.ToastUtil;
import io.agora.agoravoice.utils.UserUtil;
import io.agora.agoravoice.utils.WindowUtil;

public class SplashActivity extends BaseActivity implements
        ProxyManager.GeneralServiceListener,
        ProxyManager.UserServiceListener {
    private Dialog mUpgradeDialog;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        WindowUtil.hideStatusBar(getWindow(), false);
        initialize();
    }

    private void initialize() {
        initXLog();
        initProxy();
        checkAppVersion();
        login();
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        CropBackgroundRelativeLayout bgLayout =
                findViewById(R.id.splash_bg_layout);
        bgLayout.setCropBackground(R.drawable.splash_bg);

        DisplayMetrics metrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(metrics);

        AppCompatImageView icon = findViewById(R.id.splash_icon);
        RelativeLayout.LayoutParams params =
                (RelativeLayout.LayoutParams) icon.getLayoutParams();
        params.topMargin = metrics.heightPixels * 2 / 11;
        params.width = metrics.widthPixels / 3;
        params.height = metrics.widthPixels / 3;
        icon.setLayoutParams(params);

        AppCompatTextView appName = findViewById(R.id.splash_app_name);
        params = (RelativeLayout.LayoutParams) appName.getLayoutParams();
        params.width = metrics.widthPixels / 3;
        appName.setLayoutParams(params);

        AppCompatTextView power = findViewById(R.id.powered_by_agora);
        params = (RelativeLayout.LayoutParams) power.getLayoutParams();
        params.bottomMargin = metrics.heightPixels / 10;
        power.setLayoutParams(params);
    }

    private void checkAppVersion() {
        proxy().checkVersion(getAppVersion());
    }

    private String getAppVersion() {
        try {
            return getPackageManager().getPackageInfo(getPackageName(), 0).versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    private void initXLog() {
        LogConfiguration config = new LogConfiguration.Builder()
                .logLevel(BuildConfig.DEBUG ?
                        LogLevel.DEBUG : LogLevel.INFO)                         // Specify log level, logs below this level won't be printed, default: LogLevel.ALL
                .tag("AgoraVoice")                                              // Specify TAG, default: "X-LOG"
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

    private void initProxy() {
        proxy().addGeneralServiceListener(this);
        proxy().addUserServiceListener(this);
        proxy().getMusicList();
    }

    private void login() {
        initUserFromStorage();
        if (!config().isUserExisted()) {
            selectRandomNameIfNotExist();
            proxy().createUser(config().getNickname());
        } else {
            proxy().login(config().getUserId());
        }
    }

    private void initUserFromStorage() {
        config().setUserId(preferences().getString(Const.KEY_USER_ID, null));
        config().setNickname(preferences().getString(Const.KEY_USER_NAME, null));
        config().setUserToken(preferences().getString(Const.KEY_TOKEN, null));
    }

    private void selectRandomNameIfNotExist() {
        if (TextUtils.isEmpty(config().getNickname())) {
            config().setNickname(RandomUtil.randomUserName(this));
        }
    }

    @Override
    public void onCheckVersionSuccess(AppVersionInfo info) {
        XLog.d("onCheckVersionSuccess " + info.appVersion);
        if (info == null) {
            ToastUtil.showShortToast(SplashActivity.this, R.string.toast_app_version_fail);
            return;
        }

        runOnUiThread(() -> {
            if (info.forcedUpgrade == 2) {
                // force to upgrade
                mUpgradeDialog = DialogUtil.showDialog(SplashActivity.this,
                        R.string.dialog_upgrade_title,
                        R.string.dialog_upgrade_force_message,
                        R.string.text_upgrade,
                        R.string.text_cancel,
                        () -> {
                            dismissUpgradeDialog();
                            gotoDownloadLink(info.upgradeUrl);
                            android.os.Process.killProcess(android.os.Process.myPid());
                        },
                        () -> {
                            dismissUpgradeDialog();
                            android.os.Process.killProcess(android.os.Process.myPid());
                        }
                );
            } else if (info.forcedUpgrade == 1) {
                // recommend to upgrade
                mUpgradeDialog = DialogUtil.showDialog(SplashActivity.this,
                        R.string.dialog_upgrade_title,
                        R.string.dialog_upgrade_recommend_message,
                        R.string.text_upgrade,
                        R.string.text_cancel,
                        () -> {
                            dismissUpgradeDialog();
                            gotoDownloadLink(info.upgradeUrl);
                        },
                        SplashActivity.this::dismissUpgradeDialog
                );
            }
        });
    }

    private boolean upgradeDialogShowing() {
        return mUpgradeDialog != null && mUpgradeDialog.isShowing();
    }

    private void dismissUpgradeDialog() {
        if (upgradeDialogShowing()) {
            mUpgradeDialog.dismiss();
        }
    }

    private void gotoDownloadLink(String link) {
        if (TextUtils.isEmpty(link)) {
            ToastUtil.showShortToast(SplashActivity.this, R.string.toast_link_empty);
            return;
        }

        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri uri = Uri.parse(link);
        intent.setData(uri);
        startActivity(intent);
    }

    @Override
    public void onMusicList(List<MusicInfo> info) {
            config().updateMusicInfo(info);
    }

    @Override
    public void onGiftList(List<GiftInfo> info) {
        // Current use locally stored gift information
    }

    @Override
    public void onGeneralServiceFailed(int type, int code, String message) {

    }

    @Override
    public void onUserCreated(String userId, String userName) {
            XLog.i("agora voice application onUserCreated " +
                    userId + " " + config().getNickname());
            config().setUserId(userId);
            preferences().edit().putString(Const.KEY_USER_ID, userId).apply();
            preferences().edit().putString(Const.KEY_USER_NAME, config().getNickname()).apply();
            proxy().login(userId);
    }

    @Override
    public void onEditUser(String userId, String userName) {
        // No such operation in this Activity
    }

    @Override
    public void onLoginSuccess(String userId, String userToken, String rtmToken) {
        XLog.i("onLoginSuccess " + userToken);
        config().setUserToken(userToken);
        runOnUiThread(() -> {
            ToastUtil.showShortToast(this, "login success");
            gotoMainActivity();
        });
    }

    private void gotoMainActivity() {
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
        finish();
    }

    @Override
    public void onUserServiceFailed(int type, int code, String message) {
        if (type == BusinessType.CREATE_USER) {
            String msg = "Create user fails " + code + " " + message;
            XLog.e(msg);
            runOnUiThread(() -> ToastUtil.showShortToast(this, msg));
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        proxy().removeGeneralServiceListener(this);
        proxy().removeUserServiceListener(this);
    }
}
