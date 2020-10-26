package io.agora.agoravoice.ui.activities.main;

import android.app.Dialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.ui.NavigationUI;

import com.google.android.material.bottomnavigation.BottomNavigationView;

import java.util.List;

import io.agora.agoravoice.R;
import io.agora.agoravoice.business.definition.struct.AppVersionInfo;
import io.agora.agoravoice.business.definition.struct.GiftInfo;
import io.agora.agoravoice.business.definition.struct.MusicInfo;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.ui.activities.BaseActivity;
import io.agora.agoravoice.utils.DialogUtil;
import io.agora.agoravoice.utils.ToastUtil;
import io.agora.agoravoice.utils.WindowUtil;

public class MainActivity extends BaseActivity implements ProxyManager.GeneralServiceListener {
    private static final String TAG = MainActivity.class.getSimpleName();

    private BottomNavigationView mNavView;
    private NavController mNavController;
    private Dialog mUpgradeDialog;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowUtil.hideStatusBar(getWindow(), false);
        setContentView(R.layout.activity_main);
        initUI();
        proxy().addGeneralServiceListener(this);
        checkAppVersion();
    }

    private void initUI() {
        initNavigation();
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

    private void initNavigation() {
        mNavController = Navigation.findNavController(this, R.id.nav_host_fragment);

        mNavView = findViewById(R.id.nav_view);
        mNavView.setItemIconTintList(null);
        // changeItemHeight(mNavView);
        mNavView.setOnNavigationItemSelectedListener(item -> {
            int selectedId = item.getItemId();
            int currentId = mNavController.getCurrentDestination() == null ?
                    0 : mNavController.getCurrentDestination().getId();

            // Do not respond to this click event because
            // we do not want to refresh this fragment
            // by repeatedly selecting the same menu item.
            if (selectedId == currentId) return false;
            NavigationUI.onNavDestinationSelected(item, mNavController);
            return true;
        });
    }

    @Override
    public void onCheckVersionSuccess(AppVersionInfo info) {
        Log.d(TAG, "onCheckVersionSuccess");
        if (info == null) {
            ToastUtil.showShortToast(MainActivity.this, R.string.toast_app_version_fail);
            return;
        }

        runOnUiThread(() -> {
            if (info.forcedUpgrade == 2) {
                // force to upgrade
                mUpgradeDialog = DialogUtil.showDialog(MainActivity.this,
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
                mUpgradeDialog = DialogUtil.showDialog(MainActivity.this,
                        R.string.dialog_upgrade_title,
                        R.string.dialog_upgrade_recommend_message,
                        R.string.text_upgrade,
                        R.string.text_cancel,
                        () -> {
                            dismissUpgradeDialog();
                            gotoDownloadLink(info.upgradeUrl);
                        },
                        MainActivity.this::dismissUpgradeDialog
                );
            }
        });
    }

    @Override
    public void onMusicList(List<MusicInfo> info) {

    }

    @Override
    public void onGiftList(List<GiftInfo> info) {

    }

    @Override
    public void onGeneralServiceFailed(int type, int code, String message) {

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
            ToastUtil.showShortToast(MainActivity.this, R.string.toast_link_empty);
            return;
        }

        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri uri = Uri.parse(link);
        intent.setData(uri);
        startActivity(intent);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        proxy().removeGeneralServiceListener(this);
    }
}
