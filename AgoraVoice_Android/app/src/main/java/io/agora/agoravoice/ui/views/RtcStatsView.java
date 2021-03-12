package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.RelativeLayout;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;

import io.agora.agoravoice.R;

public class RtcStatsView extends RelativeLayout {
    private AppCompatTextView mPropTextView;
    private AppCompatTextView mStatsTextView;
    private AppCompatImageView mCloseBtn;
    private String mPropFormat;
    private String mStatsFormat;

    public RtcStatsView(Context context) {
        super(context);
        init();
    }

    public RtcStatsView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        mPropFormat = getResources().getString(R.string.rtc_starts_property_format);
        mStatsFormat = getResources().getString(R.string.rtc_stats_format);
        LayoutInflater.from(getContext()).inflate(R.layout.rtc_stats_layout, this);
        mPropTextView = findViewById(R.id.prop_text);
        mStatsTextView = findViewById(R.id.stats_text);
        mCloseBtn = findViewById(R.id.stats_close_btn);
        setProperty(0, 0);
        setLocalStats(0.0f, 0.0f, 0.0f, 0.0f, 0);
    }

    public void setProperty(int channel, int sampleRate) {
        String prop = String.format(mPropFormat, channel, sampleRate);
        mPropTextView.setText(prop);
    }

    public void setLocalStats(float rxRate, float rxLoss, float txRate, float txLoss, int latency) {
        String stats = String.format(mStatsFormat, rxRate, rxLoss, txRate, txLoss, latency);
        mStatsTextView.setText(stats);
    }

    public void setCloseListener(OnClickListener listener) {
        mCloseBtn.setOnClickListener(listener);
    }

    public void show() {
        setVisibility(VISIBLE);
    }

    public void dismiss() {
        mStatsTextView.setText("");
        setVisibility(GONE);
    }
}
