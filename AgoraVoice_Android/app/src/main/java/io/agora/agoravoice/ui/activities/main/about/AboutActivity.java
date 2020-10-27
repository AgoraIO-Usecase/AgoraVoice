package io.agora.agoravoice.ui.activities.main.about;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.appcompat.widget.AppCompatTextView;

import io.agora.agoravoice.R;
import io.agora.agoravoice.ui.activities.BaseActivity;
import io.agora.agoravoice.utils.AppUtil;
import io.agora.agoravoice.utils.WindowUtil;

public class AboutActivity extends BaseActivity implements View.OnClickListener {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_about);
        WindowUtil.hideStatusBar(getWindow(), false);
        initView();
    }

    private void initView() {
        findViewById(R.id.about_privacy_layout).setOnClickListener(this);
        findViewById(R.id.about_disclaimer_layout).setOnClickListener(this);
        findViewById(R.id.about_sign_up_layout).setOnClickListener(this);
        findViewById(R.id.about_activity_close).setOnClickListener(this);

        AppCompatTextView appVersionText =
                findViewById(R.id.about_activity_app_version_text);
        appVersionText.setText(AppUtil.getAppVersion(this));
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
        Intent intent = null;
        switch (v.getId()) {
            case R.id.about_privacy_layout:
                String link = getString(R.string.privacy_website_link);
                Uri uri = Uri.parse(link);
                intent = new Intent(Intent.ACTION_VIEW, uri);
                startActivity(intent);
                break;
            case R.id.about_disclaimer_layout:
                intent = new Intent(this, DisclaimerActivity.class);
                startActivity(intent);
                break;
            case R.id.about_sign_up_layout:
                link = getString(R.string.sign_up_website_link);
                uri = Uri.parse(link);
                intent = new Intent(Intent.ACTION_VIEW, uri);
                startActivity(intent);
                break;
            case R.id.about_activity_close:
                finish();
                break;
        }
    }
}
