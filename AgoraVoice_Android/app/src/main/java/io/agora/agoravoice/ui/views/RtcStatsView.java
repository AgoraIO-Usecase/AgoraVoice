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
    private AppCompatTextView mTextView;
    private AppCompatImageView mCloseBtn;
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
        mStatsFormat = getResources().getString(R.string.rtc_stats_format);
        LayoutInflater.from(getContext()).inflate(R.layout.rtc_stats_layout, this);
        mTextView = findViewById(R.id.stats_text);
        mCloseBtn = findViewById(R.id.stats_close_btn);
        setLocalStats(0.0f, 0.0f, 0.0f, 0.0f, 0);
    }

    public void setLocalStats(float rxRate, float rxLoss, float txRate, float txLoss, int latency) {
        String stats = String.format(mStatsFormat, rxRate, rxLoss, txRate, txLoss, latency);
        mTextView.setText(stats);
    }

    public void setCloseListener(OnClickListener listener) {
        mCloseBtn.setOnClickListener(listener);
    }

    public void show() {
        setVisibility(VISIBLE);
    }

    public void dismiss() {
        mTextView.setText("");
        setVisibility(GONE);
    }
}
