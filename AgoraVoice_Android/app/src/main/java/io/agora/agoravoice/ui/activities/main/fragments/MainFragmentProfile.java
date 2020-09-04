package io.agora.agoravoice.ui.activities.main.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;

import io.agora.agoravoice.R;
import io.agora.agoravoice.ui.activities.AboutActivity;
import io.agora.agoravoice.ui.activities.AvatarSelectActivity;
import io.agora.agoravoice.ui.activities.NicknameEditActivity;

public class MainFragmentProfile extends AbsMainFragment implements View.OnClickListener {
    private AppCompatImageView mAvatar;
    private AppCompatTextView mNickNameEdit;
    private AppCompatTextView mNickNameProfile;

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
        layout.findViewById(R.id.user_profile_avatar_setting_layout).setOnClickListener(this);
        layout.findViewById(R.id.user_profile_nickname_setting_layout).setOnClickListener(this);
        layout.findViewById(R.id.user_profile_about_layout).setOnClickListener(this);

        mAvatar = layout.findViewById(R.id.user_profile_avatar);
        mNickNameEdit = layout.findViewById(R.id.edit_profile_nickname);
        mNickNameProfile = layout.findViewById(R.id.user_profile_nickname);
        return layout;
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.user_profile_avatar_setting_layout:
                toActivity(AvatarSelectActivity.class);
                break;
            case R.id.user_profile_nickname_setting_layout:
                toActivity(NicknameEditActivity.class);
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
