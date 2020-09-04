package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.appcompat.widget.AppCompatTextView;

import java.util.Locale;

import io.agora.agoravoice.R;

public class RoomUserActionView extends RelativeLayout {
    private static final int MAX_ICON_COUNT = 4;

    public interface RoomUserActionViewListener {
        void onRoomUserActionClicked(View view);
    }

    private AppCompatTextView mCountText;
    private RelativeLayout mIconLayout;
    private View mNotification;

    private RoomUserActionViewListener mListener;

    public RoomUserActionView(Context context) {
        super(context);
        initView();
    }

    public RoomUserActionView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    private void initView() {
        LayoutInflater inflater = LayoutInflater.from(getContext());
        View layout = inflater.inflate(R.layout.room_user_action_view_layout, this);
        mIconLayout = layout.findViewById(R.id.icon_layout);
        mCountText = layout.findViewById(R.id.live_participant_count_text);

        layout.findViewById(R.id.live_participant_total_layout)
            .setOnClickListener(view -> {
                if (mListener != null) mListener.onRoomUserActionClicked(view);
            });

        mNotification = findViewById(R.id.notification_point);
    }

    public void setRoomUserActionListener(RoomUserActionViewListener listener) {
        mListener = listener;
    }

    public void reset(int total) {
        String value = countToString(total);
        mCountText.setText(value);
    }

    private String countToString(int number) {
        if (number <  1e3f) {
            return String.valueOf(number);
        } else if (number < 1e6f) {
            int quotient = (int) (number / 1e3f);
            return String.format(Locale.getDefault(), "%dK", quotient);
        } else if (number < 1e9f) {
            int quotient = (int) (number / 1e6f);
            return String.format(Locale.getDefault(), "%dM", quotient);
        } else {
            int quotient = (int) (number / 1e9f);
            return String.format(Locale.getDefault(), "%dB", quotient);
        }
    }

//    private void setUserIcons(List<EnterRoomResponse.RankInfo> rankUsers) {
//        if (mIconLayout.getChildCount() > 0) {
//            mIconLayout.removeAllViews();
//        }
//
//        if (rankUsers == null) return;
//
//        int id = 0;
//        for (int i = 0; i < rankUsers.size(); i++) {
//            if (i >= MAX_ICON_COUNT) break;
//            EnterRoomResponse.RankInfo info = rankUsers.get(i);
//            setIconResource(info.userId, id++);
//        }
//    }

    private void setIconResource(String userId, int referenceId) {
//        int resId = UserUtil.getUserProfileIcon(userId);
//        RoundedBitmapDrawable drawable = RoundedBitmapDrawableFactory.create(getResources(),
//                BitmapFactory.decodeResource(getResources(), resId));
//        drawable.setCircular(true);
//
//        LayoutParams params = new
//                LayoutParams(mIconSize, mIconSize);
//        params.rightMargin = mIconMargin;
//        if (referenceId > 0) {
//            params.addRule(RelativeLayout.LEFT_OF, referenceId);
//        } else {
//            params.addRule(RelativeLayout.ALIGN_PARENT_END, RelativeLayout.TRUE);
//        }
//
//        AppCompatImageView imageView = new AppCompatImageView(getContext());
//        imageView.setId(referenceId + 1);
//        imageView.setImageDrawable(drawable);
//        mIconLayout.addView(imageView, params);
    }

    public void showNotification(boolean show) {
        if (mNotification != null) {
            int visibility = show ? VISIBLE : GONE;
            mNotification.setVisibility(visibility);
        }
    }

    public boolean notificationShown() {
        return mNotification != null &&
                mNotification.getVisibility() == VISIBLE;
    }
}
