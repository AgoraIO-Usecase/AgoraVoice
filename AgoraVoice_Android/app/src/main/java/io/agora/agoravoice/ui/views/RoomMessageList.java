package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;

import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.GiftUtil;

public class RoomMessageList extends RecyclerView {
    public static final int MSG_TYPE_SYSTEM = 0;
    public static final int MSG_TYPE_CHAT = 1;
    public static final int MSG_TYPE_GIFT = 2;

    public static final int MSG_SYSTEM_STATE_JOIN = 1;
    public static final int MSG_SYSTEM_STATE_LEAVE = 0;

    public static final int MSG_SYSTEM_ROLE_OWNER = 1;
    public static final int MSG_SYSTEM_ROLE_HOST = 2;
    public static final int MSG_SYSTEM_ROLE_AUDIENCE = 3;

    private static final int MESSAGE_TEXT_COLOR = Color.rgb(196, 196, 196);
    private static final int MESSAGE_TEXT_COLOR_LIGHT = Color.argb(101, 35, 35, 35);
    private static final int MAX_SAVED_MESSAGE = 50;
    private static final int MESSAGE_ITEM_MARGIN = 16;

    private LiveRoomMessageAdapter mAdapter;
    private LayoutInflater mInflater;
    private LinearLayoutManager mLayoutManager;

    private String mJoinNotificationText;
    private String mLeaveNotificationText;

    private boolean mNarrow = false;

    public RoomMessageList(@NonNull Context context) {
        super(context);
        init();
    }

    public RoomMessageList(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public RoomMessageList(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void init() {
        mInflater = LayoutInflater.from(getContext());
        mAdapter = new LiveRoomMessageAdapter();
        mLayoutManager = new LinearLayoutManager(getContext(),
                LinearLayoutManager.VERTICAL, false);
        setLayoutManager(mLayoutManager);
        setAdapter(mAdapter);
        addItemDecoration(new MessageItemDecorator());

        mJoinNotificationText = getResources().getString(R.string.live_system_notification_member_joined);
        mLeaveNotificationText = getResources().getString(R.string.live_system_notification_member_left);
    }

    public void addMessage(int type, String user, String message, int... index) {
        LiveMessageItem item = new LiveMessageItem(type, user, message);
        if (type == MSG_TYPE_GIFT && index != null) {
            item.giftIndex = index[0];
            item.message = getResources().getString(R.string.live_message_gift_send);
        } else if (type == MSG_TYPE_SYSTEM) {
            if (index != null) {
                if (index[0] == 1) {
                    item.message = mJoinNotificationText;
                } else if (index[0] == 0) {
                    item.message = mLeaveNotificationText;
                }
            }
        }
        mAdapter.addMessage(item);
        mLayoutManager.scrollToPosition(mAdapter.getItemCount() - 1);
        mAdapter.notifyDataSetChanged();
    }

    private class LiveRoomMessageAdapter extends Adapter<MessageListViewHolder> {
        private ArrayList<LiveMessageItem> mMessageList = new ArrayList<>();

        @NonNull
        @Override
        public MessageListViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            if (viewType == MSG_TYPE_GIFT) {
                return new MessageListViewHolder(mInflater
                        .inflate(R.layout.message_item_gift_layout, parent, false), viewType);
            } else {
                return new MessageListViewHolder(mInflater
                        .inflate(R.layout.message_item_layout, parent, false), viewType);
            }
        }

        @Override
        public void onBindViewHolder(@NonNull MessageListViewHolder holder, int position) {
            LiveMessageItem item = mMessageList.get(position);
            holder.setMessage(item.user, item.message);
            if (item.type == MSG_TYPE_GIFT && holder.giftIcon != null) {
                holder.giftIcon.setImageResource(GiftUtil.GIFT_ICON_RES[item.giftIndex]);
            }
        }

        @Override
        public int getItemCount() {
            return mMessageList.size();
        }

        @Override
        public int getItemViewType(int position) {
            return mMessageList.get(position).type;
        }

        void addMessage(LiveMessageItem item) {
            if (mMessageList.size() == MAX_SAVED_MESSAGE) {
                mMessageList.remove(mMessageList.size() - 1);
            }
            mMessageList.add(item);
        }
    }

    private class MessageListViewHolder extends ViewHolder {
        private AppCompatTextView messageText;
        private AppCompatImageView giftIcon;
        private RelativeLayout layout;
        private int type;

        MessageListViewHolder(@NonNull View itemView, int type) {
            super(itemView);
            messageText = itemView.findViewById(R.id.live_message_item_text);
            giftIcon = itemView.findViewById(R.id.live_message_gift_icon);
            layout = itemView.findViewById(R.id.live_message_item_layout);
            this.type = type;
        }

        void setMessage(String user, String message) {
            int background = R.drawable.round_scalable_gray_bg;
            int nameColor = Color.WHITE;
            int messageColor = MESSAGE_TEXT_COLOR;

            layout.setBackgroundResource(background);

            String text = mNarrow ? user + ": " : user + ":  " + message;
            SpannableString messageSpan = new SpannableString(text);
            messageSpan.setSpan(new StyleSpan(Typeface.BOLD),
                    0, user.length() + 1, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
            messageSpan.setSpan(new ForegroundColorSpan(nameColor),
                    0, user.length() + 1, Spannable.SPAN_INCLUSIVE_INCLUSIVE);

            if (!mNarrow || this.type != MSG_TYPE_GIFT) {
                messageSpan.setSpan(new ForegroundColorSpan(messageColor),
                        user.length() + 2, messageSpan.length(),
                        Spannable.SPAN_INCLUSIVE_INCLUSIVE);
            }

            messageText.setText(messageSpan);
        }
    }

    private static class MessageItemDecorator extends ItemDecoration {
        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                                   @NonNull RecyclerView parent, @NonNull State state) {
            super.getItemOffsets(outRect, view, parent, state);
            outRect.top = MESSAGE_ITEM_MARGIN;
            outRect.bottom = MESSAGE_ITEM_MARGIN;

        }
    }

    private static class LiveMessageItem {
        int type;
        String user;
        String message;
        int giftIndex;

        LiveMessageItem(int type, String user, String message) {
            this.type = type;
            this.user = user;
            this.message = message;
        }
    }
}
