package io.agora.agoravoice.ui.activities.main.about;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;

import java.io.File;

import io.agora.agoravoice.R;
import io.agora.agoravoice.business.log.LogUploader;
import io.agora.agoravoice.business.server.retrofit.listener.LogServiceListener;
import io.agora.agoravoice.ui.activities.BaseActivity;
import io.agora.agoravoice.utils.AppUtil;
import io.agora.agoravoice.utils.ClipboardUtils;
import io.agora.agoravoice.utils.ToastUtil;
import io.agora.agoravoice.utils.UserUtil;
import io.agora.agoravoice.utils.WindowUtil;
import io.agora.log.AgoraLogManager;

public class AboutActivity extends BaseActivity implements View.OnClickListener {
    private static final String TAG = AboutActivity.class.getSimpleName();

    private RelativeLayout mPrivacyLayout;
    private RelativeLayout mDisclaimerLayout;
    private RelativeLayout mSignUpLayout;
    private RelativeLayout mUploadLogLayout;
    private AppCompatImageView mClose;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_about);
        WindowUtil.hideStatusBar(getWindow(), false);
        initView();
    }

    private void initView() {
        mPrivacyLayout = findViewById(R.id.about_privacy_layout);
        mPrivacyLayout.setOnClickListener(this);
        mDisclaimerLayout = findViewById(R.id.about_disclaimer_layout);
        mDisclaimerLayout.setOnClickListener(this);
        mSignUpLayout = findViewById(R.id.about_sign_up_layout);
        mSignUpLayout.setOnClickListener(this);
        mUploadLogLayout = findViewById(R.id.about_upload_log_layout);
        mUploadLogLayout.setOnClickListener(this);
        mClose = findViewById(R.id.about_activity_close);
        mClose.setOnClickListener(this);

        AppCompatTextView appVersionText =
                findViewById(R.id.about_activity_app_version_text);
        appVersionText.setText(AppUtil.getAppVersion(this));

        AppCompatTextView rteVersionText
                = findViewById(R.id.about_activity_rte_version);
        rteVersionText.setText(proxy().getServiceVersion());
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        RelativeLayout titleLayout = findViewById(R.id.activity_privacy_title_layout);
        if (titleLayout != null) {
            RelativeLayout.LayoutParams params =
                    (RelativeLayout.LayoutParams) titleLayout.getLayoutParams();
            params.topMargin += systemBarHeight;
            titleLayout.setLayoutParams(params);
        }
    }

    @Override
    public void onClick(View v) {
        Intent intent;
        int id = v.getId();
        if (id == mPrivacyLayout.getId()) {
            String link = getString(R.string.privacy_website_link);
            Uri uri = Uri.parse(link);
            intent = new Intent(Intent.ACTION_VIEW, uri);
            startActivity(intent);
        } else if (id == mDisclaimerLayout.getId()) {
            intent = new Intent(this, DisclaimerActivity.class);
            startActivity(intent);
        } else if (id == mSignUpLayout.getId()) {
            String link = getString(R.string.sign_up_website_link);
            Uri uri = Uri.parse(link);
            intent = new Intent(Intent.ACTION_VIEW, uri);
            startActivity(intent);
        } else if (id == mUploadLogLayout.getId()) {
            uploadLog();
        } else if (id == mClose.getId()) {
            finish();
        }
    }

    private void uploadLog() {
        proxy().uploadLogs(new LogServiceListener() {
            @Override
            public void onOssUploadSuccess(String data) {
                ClipboardUtils.copyText(application(), "Log id", data);
                String message = getResources().getString(
                        R.string.upload_log_success_message_format);
                final String successMessage = String.format(message, data);
                runOnUiThread(() -> ToastUtil.showShortToast(application(), successMessage));
            }

            @Override
            public void onOssUploadFail(int requestType, String message) {
                String toast = getResources().getString(
                        R.string.upload_log_fail_message_format);
                final String toastMessage = String.format(toast, message);
                runOnUiThread(() -> ToastUtil.showShortToast(application(), toastMessage));
            }
        });
    }
}
