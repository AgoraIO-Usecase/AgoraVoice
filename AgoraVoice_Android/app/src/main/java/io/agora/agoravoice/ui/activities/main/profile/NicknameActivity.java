package io.agora.agoravoice.ui.activities.main.profile;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.Toast;

import androidx.appcompat.widget.AppCompatEditText;

import io.agora.agoravoice.R;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.ui.activities.BaseActivity;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.ToastUtil;
import io.agora.agoravoice.utils.WindowUtil;

public class NicknameActivity extends BaseActivity implements View.OnClickListener {
    private AppCompatEditText mNameEdit;

    private ProxyManager.UserServiceListener mUserListener = new
            ProxyManager.UserServiceListener() {
                @Override
                public void onUserCreated(String userId, String userName) {

                }

                @Override
                public void onEditUser(String userId, String userName) {
                    runOnUiThread(() -> {
                        config().setNickname(userName);
                        preferences().edit().putString(Const.KEY_USER_NAME, userName).apply();
                        ToastUtil.showShortToast(application(),
                                R.string.profile_name_edit_message_success);
                        finish();
                    });
                }

                @Override
                public void onLoginSuccess(String userId, String userToken, String rtmToken) {

                }

                @Override
                public void onUserServiceFailed(int type, int code, String message) {
                    runOnUiThread(() -> ToastUtil.showShortToast(application(),
                            R.string.profile_name_edit_message_fail));
                }
            };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowUtil.hideStatusBar(getWindow(), false);
        setContentView(R.layout.activity_edit_nickname);
        initView();
        proxy().addUserServiceListener(mUserListener);
    }

    private void initView() {
        findViewById(R.id.main_profile_edit_confirm).setOnClickListener(this);
        findViewById(R.id.main_profile_edit_cancel).setOnClickListener(this);

        mNameEdit = findViewById(R.id.profile_nickname_edit_text);
        mNameEdit.setText(config().getNickname());
        mNameEdit.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        RelativeLayout topLayout = findViewById(R.id.avatar_edit_top_layout);
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
                editName();
                break;
            case R.id.main_profile_edit_cancel:
                finish();
                break;
        }
    }

    private void editName() {
        String name = mNameEdit == null ? null
                : mNameEdit.getEditableText().toString();
        if (!TextUtils.isEmpty(name)) {
            proxy().editUser(config().getUserToken(),
                    config().getUserId(), name);
        } else if (config().getNickname().equals(name)) {
            ToastUtil.showShortToast(application(),
                    R.string.profile_name_edit_message_same);
        } else {
            ToastUtil.showShortToast(application(),
                    R.string.profile_name_edit_message_empty);
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        proxy().removeUserServiceListener(mUserListener);
    }
}
