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
    public static final int MSG_TYPE_JOIN = 0;
    public static final int MSG_TYPE_LEAVE = 1;
    public static final int MSG_TYPE_CHAT = 2;
    public static final int MSG_TYPE_GIFT = 3;
    public static final int MSG_TYPE_TEXT = 4;

    private static final int MESSAGE_TEXT_COLOR = Color.rgb(196, 196, 196);
    private static final int MAX_SAVED_MESSAGE = 50;
    private static final int MESSAGE_ITEM_MARGIN = 16;

    private LiveRoomMessageAdapter mAdapter;
    private LayoutInflater mInflater;
    private LinearLayoutManager mLayoutManager;

    private String mJoinHintText;
    private String mLeaveHintText;
    private String mGiftSendHintText;

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

        mJoinHintText = getResources().getString(R.string.live_system_notification_member_joined);
        mLeaveHintText = getResources().getString(R.string.live_system_notification_member_left);
        mGiftSendHintText = getResources().getString(R.string.live_message_gift_send);
    }

    public void addJoinMessage(String user) {
        LiveMessageItem item = new LiveMessageItem(MSG_TYPE_JOIN, user, mJoinHintText);
        addMessage(item);
    }

    public void addLeaveMessage(String user) {
        LiveMessageItem item = new LiveMessageItem(MSG_TYPE_LEAVE, user, mLeaveHintText);
        addMessage(item);
    }

    public void addGiftSendMessage(String fromUser, String toUser, int giftIndex) {
        String message = String.format(mGiftSendHintText, toUser);
        LiveMessageItem item = new LiveMessageItem(MSG_TYPE_GIFT, fromUser, message);
        item.giftIndex = giftIndex;
        item.toUser = toUser;
        addMessage(item);
    }

    public void addChatMessage(String user, String message) {
        LiveMessageItem item = new LiveMessageItem(MSG_TYPE_CHAT, user, message);
        addMessage(item);
    }

    public void addTextMessage(String user, String message) {
        LiveMessageItem item = new LiveMessageItem(MSG_TYPE_TEXT, user, message);
        addMessage(item);
    }

    private void addMessage(LiveMessageItem item) {
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
            holder.setMessage(item.fromUser, item.message);
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

    private static class MessageListViewHolder extends ViewHolder {
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
            int background = R.drawable.message_list_item_background;
            int nameColor = Color.WHITE;
            layout.setBackgroundResource(background);

            String text;
            if (type == MSG_TYPE_CHAT) {
                text = user + ":  " + message;
            } else {
                text = user + "  " + message;
            }

            SpannableString messageSpan = new SpannableString(text);
            messageSpan.setSpan(new StyleSpan(Typeface.BOLD),
                    0, user.length() + 1, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
            messageSpan.setSpan(new ForegroundColorSpan(nameColor),
                    0, user.length() + 1, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
            messageSpan.setSpan(new ForegroundColorSpan(MESSAGE_TEXT_COLOR),
                    user.length() + 2, messageSpan.length(),
                    Spannable.SPAN_INCLUSIVE_EXCLUSIVE);

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
        String fromUser;
        String message;
        String toUser;
        int giftIndex;

        LiveMessageItem(int type, String user, String message) {
            this.type = type;
            this.fromUser = user;
            this.message = message;
        }
    }
}
