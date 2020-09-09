package io.agora.agoravoice.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.RelativeLayout;

import io.agora.agoravoice.R;

public class AboutActivity extends BaseActivity implements View.OnClickListener {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_about);
        initView();
    }

    private void initView() {
        findViewById(R.id.about_privacy_layout).setOnClickListener(this);
        findViewById(R.id.about_disclaimer_layout).setOnClickListener(this);
        findViewById(R.id.about_sign_up_layout).setOnClickListener(this);
        findViewById(R.id.about_activity_close).setOnClickListener(this);
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        RelativeLayout titleLayout = findViewById(R.id.activity_about_title_layout);
        if (titleLayout != null) {
            RelativeLayout.LayoutParams params =
                    (RelativeLayout.LayoutParams) titleLayout.getLayoutParams();
            params.topMargin += systemBarHeight;
            titleLayout.setLayoutParams(params);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.about_privacy_layout:
                break;
            case R.id.about_disclaimer_layout:
                break;
            case R.id.about_sign_up_layout:
                break;
            case R.id.about_activity_close:
                break;
        }
    }
}
