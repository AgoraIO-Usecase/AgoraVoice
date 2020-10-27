package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.appcompat.widget.AppCompatImageView;

import io.agora.agoravoice.R;

public class MainNavigation extends RelativeLayout implements View.OnClickListener{
    public interface OnNavigationItemClickListener {
        void onNavigationItemClicked(int position);
    }

    private AppCompatImageView mBtn1;
    private AppCompatImageView mBtn2;

    private OnNavigationItemClickListener mListener;

    public MainNavigation(Context context) {
        super(context);
        init();
    }

    public MainNavigation(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.main_navigation, this);
        mBtn1 = findViewById(R.id.main_navigation_btn1);
        mBtn1.setOnClickListener(this);
        mBtn2 = findViewById(R.id.main_navigation_btn2);
        mBtn2.setOnClickListener(this);
    }

    public void setListener(OnNavigationItemClickListener listener) {
        mListener = listener;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.main_navigation_btn1:
                if (mListener != null) mListener.onNavigationItemClicked(0);
                mBtn1.setActivated(true);
                mBtn2.setActivated(false);
                break;
            case R.id.main_navigation_btn2:
                if (mListener != null) mListener.onNavigationItemClicked(1);
                mBtn1.setActivated(false);
                mBtn2.setActivated(true);
                break;
        }
    }
}
