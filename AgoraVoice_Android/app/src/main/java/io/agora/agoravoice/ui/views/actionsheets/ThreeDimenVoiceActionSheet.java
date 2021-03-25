package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.SeekBar;

import androidx.appcompat.widget.AppCompatImageView;

import io.agora.agoravoice.Config;
import io.agora.agoravoice.R;
import io.agora.agoravoice.manager.AudioManager;

public class ThreeDimenVoiceActionSheet extends AbstractActionSheet
        implements View.OnClickListener, SeekBar.OnSeekBarChangeListener {
    private static final int MAX_VOICE_SPEED = 60;
    private static final int MIN_VOICE_SPEED = 1;

    public interface ThreeDimenVoiceActionListener {
        void onThreeDimenVoiceEnabled(boolean enabled);
        void onThreeDimenVoiceSpeedChanged(int speed);
        void onThreeDimenVoiceActionClosed();
    }

    private AppCompatImageView mSwitch;
    private SeekBar mValueBar;
    private Config mConfig;
    private ThreeDimenVoiceActionListener mListener;

    public ThreeDimenVoiceActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(
                R.layout.action_sheet_sound_effect_3d_voice, this);
        mValueBar = findViewById(R.id.action_sheet_3d_voice_speed_bar);
        mValueBar.setMax(MAX_VOICE_SPEED);
        mValueBar.setOnSeekBarChangeListener(this);

        findViewById(R.id.action_sheet_3d_voice_back).setOnClickListener(this);

        mSwitch = findViewById(R.id.action_sheet_electronic_switch);
        mSwitch.setOnClickListener(view -> {
            if (view.isActivated()) {
                view.setActivated(false);
                mValueBar.setEnabled(false);
                if (mListener != null) mListener.onThreeDimenVoiceEnabled(false);
            } else {
                view.setActivated(true);
                mValueBar.setEnabled(true);
                if (mListener != null) mListener.onThreeDimenVoiceEnabled(true);
            }
        });
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.action_sheet_3d_voice_back:
                if (mListener != null) mListener.onThreeDimenVoiceActionClosed();
                break;
        }
    }

    public void setThreeDimenVoiceActionListener(ThreeDimenVoiceActionListener listener) {
        mListener = listener;
    }

    public void setConfig(Config config) {
        mConfig = config;
    }

    public void setup() {
        mValueBar.setProgress(getVoiceSpeed());
        if (threeDimenVoiceEnabled()) {
            mSwitch.setActivated(true);
            mValueBar.setEnabled(true);
        } else {
            mSwitch.setActivated(false);
            mValueBar.setEnabled(false);
        }
    }

    private boolean threeDimenVoiceEnabled() {
        return mConfig != null && mConfig.getCurAudioEffect() == AudioManager.EFFECT_SPACING_3D_VOICE;
    }

    private int getVoiceSpeed() {
        return mConfig == null ? 0 : mConfig.get3DVoiceSpeed();
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {
        if (threeDimenVoiceEnabled() && mListener != null) {
            int progress = seekBar.getProgress();
            if (progress < MIN_VOICE_SPEED) {
                seekBar.setProgress(MIN_VOICE_SPEED);
                progress = MIN_VOICE_SPEED;
            }

            mListener.onThreeDimenVoiceSpeedChanged(
                    progress < 0 ? 0 : Math.min(progress, MAX_VOICE_SPEED));
        }
    }
}
