package io.agora.agoravoice.ui.views.bottombar;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;

import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.Const;

public abstract class AbsBottomBar extends RelativeLayout implements View.OnClickListener {
    private static final int BUTTON_COUNT = 4;

    // The bottom buttons are arranged from right to left
    private AppCompatImageView[] mButtons;
    private AppCompatTextView mInputHint;

    private Const.Role mRole = Const.Role.audience;
    private BottomBarConfig mConfig;

    private BottomBarListener mListener;

    public interface BottomBarListener {
        void onTextEditClicked();
        void onButtonClicked(Const.Role role, View view, int index);
    }

    public AbsBottomBar(Context context) {
        super(context);
        init();
    }

    public AbsBottomBar(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public abstract BottomBarConfig onGetConfig();

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.room_bottom_bar_layout, this, true);

        mButtons = new AppCompatImageView[BUTTON_COUNT];
        mButtons[0] = findViewById(R.id.room_bottom_btn_1);
        mButtons[1] = findViewById(R.id.room_bottom_btn_2);
        mButtons[2] = findViewById(R.id.room_bottom_btn_3);
        mButtons[3] = findViewById(R.id.room_bottom_btn_4);
        mInputHint = findViewById(R.id.room_bottom_bar_input_hint);

        mButtons[0].setOnClickListener(this);
        mButtons[1].setOnClickListener(this);
        mButtons[2].setOnClickListener(this);
        mButtons[3].setOnClickListener(this);
        mInputHint.setOnClickListener(this);

        mConfig = onGetConfig();
        reset();
    }

    private void reset() {
        if (mConfig == null) {
            return;
        }

        for (AppCompatImageView image : mButtons) {
            image.setVisibility(GONE);
        }

        for (int i = 0; i < BUTTON_COUNT; i++) {
            BottomBarConfig.BottomBarButtonConfigWithRole
                    configWithRole = mConfig.buttonConfigs.get(i);
            if (configWithRole == null) break;
            BottomBarConfig.BottomBarButtonConfig config = configWithRole.configs.get(mRole);
            if (config == null) break;
            if (config.show) {
                mButtons[i].setVisibility(VISIBLE);
                mButtons[i].setImageResource(config.icon);
            } else {
                mButtons[i].setVisibility(GONE);
            }
        }
    }

    public void setRole(Const.Role role) {
        mRole = role;
        reset();
    }

    @Override
    public void onClick(View view) {
        if (mListener != null) {
            switch (view.getId()) {
                case R.id.room_bottom_bar_input_hint:
                    mListener.onTextEditClicked();
                    break;
                case R.id.room_bottom_btn_1:
                    mListener.onButtonClicked(mRole, view, 0);
                    break;
                case R.id.room_bottom_btn_2:
                    mListener.onButtonClicked(mRole, view, 1);
                    break;
                case R.id.room_bottom_btn_3:
                    mListener.onButtonClicked(mRole, view, 2);
                    break;
                case R.id.room_bottom_btn_4:
                    mListener.onButtonClicked(mRole, view, 3);
                    break;
            }
        }
    }

    public void setBottomBarListener(BottomBarListener listener) {
        mListener = listener;
    }
}
