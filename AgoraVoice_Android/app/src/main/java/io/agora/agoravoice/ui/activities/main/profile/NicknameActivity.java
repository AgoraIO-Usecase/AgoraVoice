package io.agora.agoravoice.ui.activities.main.profile;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.appcompat.widget.AppCompatEditText;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.agora.agoravoice.R;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.ui.activities.BaseActivity;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.ToastUtil;
import io.agora.agoravoice.utils.WindowUtil;

public class NicknameActivity extends BaseActivity implements View.OnClickListener, TextWatcher {
    private static final int TOAST_DURATION = 3000;
    private static final int NAME_MAX_LENGTH = 16;
    private static final String NAME_FORMAT = "[a-zA-Z_0-9\u4e00-\u9fa5\\s]*";

    private AppCompatEditText mNameEdit;
    private Pattern mPattern;
    private long mLastToastTime;

    private final ProxyManager.UserServiceListener mUserListener =
            new ProxyManager.UserServiceListener() {
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
        mNameEdit.addTextChangedListener(this);

        mPattern = Pattern.compile(NAME_FORMAT);
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

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {

    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        Matcher matcher = mPattern.matcher(s.toString());
        if (matcher.matches()) return;

        StringBuilder builder = new StringBuilder();
        while (matcher.find()) {
            String str = matcher.group();
            builder.append(str);
        }

        int selection;
        if (count < before) {
            // characters are deleted or replaced
            selection = start;
        } else {
            selection = start + count;
        }

        if (builder.length() != s.length()) {
            // If there is any invalid character removed,
            // set the selection to the end of string
            selection = builder.length();
        }

        setNameText(builder.toString(), selection);
    }

    @Override
    public void afterTextChanged(Editable s) {
        if (s.length() > NAME_MAX_LENGTH) {
            long now = System.currentTimeMillis();
            if (now - mLastToastTime >= TOAST_DURATION) {
                // Avoid showing too much toast dialog at once
                String format = getString(R.string.profile_name_too_long_toast_message);
                String message = String.format(format, NAME_MAX_LENGTH);
                ToastUtil.showShortToast(NicknameActivity.this, message);
                mLastToastTime = now;
            }

            setNameText(s.subSequence(0, NAME_MAX_LENGTH).toString(), NAME_MAX_LENGTH);
        }
    }

    private void setNameText(String content, int selection) {
        mNameEdit.removeTextChangedListener(this);
        mNameEdit.setText(content);
        if (selection > 0) mNameEdit.setSelection(selection);
        mNameEdit.addTextChangedListener(this);
    }

    private void editName() {
        String name = mNameEdit == null ? null
                : mNameEdit.getEditableText().toString().trim();
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
