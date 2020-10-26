package io.agora.agoravoice.ui.activities.main.about;

import android.os.Bundle;
import android.view.View;
import android.widget.RelativeLayout;

import io.agora.agoravoice.R;
import io.agora.agoravoice.ui.activities.BaseActivity;
import io.agora.agoravoice.utils.WindowUtil;

public class DisclaimerActivity extends BaseActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_disclaimer);
        WindowUtil.hideStatusBar(getWindow(), false);

        findViewById(R.id.disclaimer_close).setOnClickListener(view -> finish());
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        View topLayout = findViewById(R.id.activity_disclaimer_title_layout);
        if (topLayout != null) {
            RelativeLayout.LayoutParams params =
                    (RelativeLayout.LayoutParams)
                            topLayout.getLayoutParams();
            params.topMargin += systemBarHeight;
            topLayout.setLayoutParams(params);
        }
    }
}
