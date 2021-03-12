package io.agora.agoravoice.ui.activities.main.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;

import io.agora.agoravoice.R;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.ui.activities.main.about.AboutActivity;
import io.agora.agoravoice.ui.activities.main.profile.NicknameActivity;
import io.agora.agoravoice.utils.UserUtil;
import io.agora.agoravoice.utils.WindowUtil;

public class MainFragmentProfile extends AbsMainFragment implements View.OnClickListener {
    private AppCompatImageView mAvatar;
    private AppCompatTextView mNickNameEdit;
    private AppCompatTextView mNickNameProfile;

    private ProxyManager.UserServiceListener mUserServiceListener
            = new ProxyManager.UserServiceListener() {
        @Override
        public void onUserCreated(String userId, String userName) {

        }

        @Override
        public void onEditUser(String userId, String userName) {

        }

        @Override
        public void onLoginSuccess(String userId, String userToken, String rtmToken) {
            getActivity().runOnUiThread(() -> initUserInfo());
            application().proxy().removeUserServiceListener(mUserServiceListener);
        }

        @Override
        public void onUserServiceFailed(int type, int code, String message) {
            application().proxy().removeUserServiceListener(mUserServiceListener);
        }
    };

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View layout = LayoutInflater.from(getContext())
                .inflate(R.layout.fragment_profile, container, false);
        adjustScreen(layout);
        layout.findViewById(R.id.user_profile_nickname_setting_layout).setOnClickListener(this);
        layout.findViewById(R.id.user_profile_about_layout).setOnClickListener(this);

        mAvatar = layout.findViewById(R.id.user_profile_avatar);
        mNickNameEdit = layout.findViewById(R.id.edit_profile_nickname);
        mNickNameProfile = layout.findViewById(R.id.user_profile_nickname);
        return layout;
    }

    private void adjustScreen(View layout) {
        RelativeLayout topLayout = layout.findViewById(R.id.profile_top_layout);
        RelativeLayout.LayoutParams params =
                (RelativeLayout.LayoutParams) topLayout.getLayoutParams();
        params.topMargin += WindowUtil.getStatusBarHeight(getContext());
        topLayout.setLayoutParams(params);
    }

    @Override
    public void onResume() {
        super.onResume();
        if (userValid()) {
            initUserInfo();
        } else {
            tryLogin();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        application().proxy().removeUserServiceListener(mUserServiceListener);
    }

    private void initUserInfo() {
        mAvatar.setImageDrawable(UserUtil.getUserRoundIcon(
                getResources(), application().config().getUserId()));
        mNickNameProfile.setText(application().config().getNickname());
        mNickNameEdit.setText(application().config().getNickname());
    }

    private boolean userValid() {
        return application().config().isUserExisted() &&
                application().config().userHasLogin();
    }

    private void tryLogin() {
        application().proxy().addUserServiceListener(mUserServiceListener);
        application().proxy().login(application().config().getUserId());
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.user_profile_nickname_setting_layout:
                toActivity(NicknameActivity.class);
                break;
            case R.id.user_profile_about_layout:
                toActivity(AboutActivity.class);
                break;
        }
    }

    private void toActivity(Class<?> activityClass) {
        Intent intent = new Intent(getContext(), activityClass);
        startActivity(intent);
    }
}
