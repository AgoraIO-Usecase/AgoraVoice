package io.agora.agoravoice.ui.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.RelativeLayout;

import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.WindowUtil;

public class NicknameEditActivity extends BaseActivity implements View.OnClickListener {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowUtil.hideStatusBar(getWindow(), false);
        setContentView(R.layout.activity_edit_nickname);
        initView();
    }

    private void initView() {
        findViewById(R.id.main_profile_edit_confirm).setOnClickListener(this);
        findViewById(R.id.main_profile_edit_cancel).setOnClickListener(this);
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        RelativeLayout topLayout = findViewById(R.id.name_edit_top_color_layout);
        if (topLayout != null) {
            RelativeLayout.LayoutParams params =
                    (RelativeLayout.LayoutParams) topLayout.getLayoutParams();
            params.topMargin += systemBarHeight;
            topLayout.setLayoutParams(params);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.main_profile_edit_confirm:
            case R.id.main_profile_edit_cancel:
                break;
        }
    }
}
