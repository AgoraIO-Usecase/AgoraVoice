package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.core.graphics.drawable.RoundedBitmapDrawable;

import java.util.List;
import java.util.Locale;

import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.UserUtil;

public class RoomUserActionView extends RelativeLayout {
    private static final int MAX_ICON_COUNT = 4;

    public interface RoomUserActionViewListener {
        void onRoomUserActionClicked(View view);
    }

    private AppCompatTextView mCountText;
    private RelativeLayout mIconLayout;
    private View mNotification;

    private int mUserIconSize;
    private int mUserIconMargin;

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
        mUserIconSize = getResources().getDimensionPixelSize(R.dimen.room_user_action_view_height);
        mUserIconMargin = getResources().getDimensionPixelOffset(R.dimen.margin_1);

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

    public void resetCount(int total) {
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

    public void setUserIcons(List<String> rankUsers) {
        if (mIconLayout.getChildCount() > 0) {
            mIconLayout.removeAllViews();
        }

        if (rankUsers == null) return;

        int id = 0;
        for (int i = rankUsers.size() - 1; i >= 0; i--) {
            if (i >= MAX_ICON_COUNT) break;
            setIconResource(rankUsers.get(i), id++);
        }
    }

    private void setIconResource(String userId, int referenceId) {
        RoundedBitmapDrawable drawable = UserUtil.getUserRoundIcon(getResources(), userId);
        LayoutParams params = new LayoutParams(mUserIconSize, mUserIconSize);
        params.rightMargin = mUserIconMargin;

        if (referenceId > 0) {
            params.addRule(RelativeLayout.LEFT_OF, referenceId);
        } else {
            params.addRule(RelativeLayout.ALIGN_PARENT_END, RelativeLayout.TRUE);
        }

        AppCompatImageView imageView = new AppCompatImageView(getContext());
        imageView.setId(referenceId + 1);
        imageView.setImageDrawable(drawable);
        mIconLayout.addView(imageView, params);
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
