package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

import io.agora.agoravoice.R;
import io.agora.agoravoice.business.definition.struct.RoomUserInfo;
import io.agora.agoravoice.manager.InvitationManager;
import io.agora.agoravoice.utils.UserUtil;

public class UserListActionSheet extends AbstractActionSheet implements View.OnClickListener {
    private int mTextColorDefault = Color.parseColor("#FFababab");

    public interface UserListActionSheetListener {
        void onUserInvited(int no, String userId, String userName);
        void onApplicationAccepted(int no, String userId, String userName);
        void onApplicationRejected(int no, String userId, String userName);
    }

    private RelativeLayout mTypeLayout;
    private RelativeLayout mLeftTitleLayout;
    private RelativeLayout mRightTitleLayout;
    private TextView mAllUserTitle;
    private TextView mApplicationTitle;
    private View mAllUserTitleIndicator;
    private View mApplicationTitleIndicator;
    private View mNotification;
    private boolean mDefaultShowAll = true;
    private boolean mIsOwner;
    private boolean mShowInvite;
    private String mOwnerId;
    private int mInviteSeatNo;

    private RecyclerView mUserListRecycler;
    private UserListAdapter mAllUserAdapter;
    private UserApplyAdapter mApplyAdapter;
    private UserListActionSheetListener mListener;
    private InvitationManager mInviteManager;

    public UserListActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.user_list_action, this);

        mTypeLayout = findViewById(R.id.action_sheet_online_user_type_layout);

        mLeftTitleLayout = findViewById(R.id.online_user_type_title_layout_left);
        mLeftTitleLayout.setOnClickListener(this);
        mRightTitleLayout = findViewById(R.id.online_user_type_title_layout_right);
        mRightTitleLayout.setOnClickListener(this);

        mAllUserTitle = findViewById(R.id.online_user_text_all);
        mAllUserTitleIndicator = findViewById(R.id.online_user_tab_all_indicator);
        mApplicationTitle = findViewById(R.id.online_user_text_application);
        mApplicationTitleIndicator = findViewById(R.id.online_user_text_application_indicator);

        mNotification = findViewById(R.id.notification_point);
        mNotification.setVisibility(View.GONE);

        mUserListRecycler = findViewById(R.id.action_sheet_online_user_recycler);
        mUserListRecycler.setLayoutManager(new LinearLayoutManager(
                getContext(), LinearLayoutManager.VERTICAL, false));

        mAllUserAdapter = new UserListAdapter();
        mApplyAdapter = new UserApplyAdapter();
    }

    public void setOwner(boolean meIsOwner, String ownerId) {
        mIsOwner = meIsOwner;
        mOwnerId = ownerId;
        if (mIsOwner) {
            showTab();
        } else {
            hideTab();
        }
    }

    /**
     * If multiple tabs show.
     * Must be called after setOwner is called, because
     * owners have different tab setting
     * @param show
     */
    public void showTab(boolean show) {
        if (show) showTab();
        else hideTab();
    }

    // Note: must be called before the user list is updated
    // and the action sheet is shown
    public void showInviteStatus(boolean show) {
        mShowInvite = show;
    }

    // Only used when inviting a user for a
    // specific seat
    public void setSeatNo(int no) {
        mInviteSeatNo = no;
    }

    public void setInvitationManager(InvitationManager manager) {
        mInviteManager = manager;
    }

    public void setUserActionSheetListener(UserListActionSheetListener listener) {
        mListener = listener;
    }

    // Update list when this action sheet is shown
    public void updateUserList(List<String> excludedIds) {
        if (getVisibility() == VISIBLE && mInviteManager != null) {
            List<RoomUserInfo> allList = new ArrayList<>(mInviteManager.getFullUserList());

            if (mShowInvite) {
                // If this is for seat invitation, exclude room
                // owner himself and any user that has taken
                // a seat
                List<Integer> deleteList = new ArrayList<>();
                if (excludedIds != null) {
                    for (int i = allList.size() - 1; i >= 0; i--) {
                        RoomUserInfo info = allList.get(i);
                        if (excludedIds.contains(info.userId) ||
                                info.userId.equals(mOwnerId)) {
                            deleteList.add(i);
                        }
                    }

                }

                for (int index : deleteList) {
                    allList.remove(index);
                }
            }

            mAllUserAdapter.reset(allList);
            mApplyAdapter.reset(mInviteManager.getApplicationList());
        }
    }

    public void changeTab() {
        mDefaultShowAll = !mDefaultShowAll;
        showTab();
    }

    private void showTab() {
        mTypeLayout.setVisibility(VISIBLE);
        showTabHighlight();
        mUserListRecycler.setAdapter(getCurrentAdapter());
    }

    private void showTabHighlight() {
        if (mDefaultShowAll) {
            setBoldText(mAllUserTitle, true);
            setBoldText(mApplicationTitle, false);
            mAllUserTitleIndicator.setVisibility(VISIBLE);
            mApplicationTitleIndicator.setVisibility(GONE);
        } else {
            setBoldText(mAllUserTitle, false);
            setBoldText(mApplicationTitle, true);
            mAllUserTitleIndicator.setVisibility(GONE);
            mApplicationTitleIndicator.setVisibility(VISIBLE);
            mNotification.setVisibility(GONE);
        }
    }

    private void hideTab() {
        mTypeLayout.setVisibility(GONE);
        mDefaultShowAll = true;
        mUserListRecycler.setAdapter(getCurrentAdapter());
    }

    private void setBoldText(TextView text, boolean bold) {
        text.setTypeface(bold ? Typeface.DEFAULT_BOLD : Typeface.DEFAULT);
        text.setTextColor(bold ? Color.WHITE : mTextColorDefault);
    }

    private RecyclerView.Adapter<?> getCurrentAdapter() {
        return mDefaultShowAll ? mAllUserAdapter : mApplyAdapter;
    }

    public void showApplication(boolean show) {
        if (show && mDefaultShowAll) {
            if (isShown()) {
                mNotification.setVisibility(VISIBLE);
            } else {
                changeTab();
            }
        } else {
            mNotification.setVisibility(GONE);
        }
    }

    private class UserListAdapter extends RecyclerView.Adapter<UserListViewHolder> {
        private List<RoomUserInfo> mList = new ArrayList<>();

        @NonNull
        @Override
        public UserListViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new UserListViewHolder(LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.action_sheet_online_user_list_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull UserListViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            int total = mList.size();
            if (pos >= total) return;
            RoomUserInfo info = mList.get(pos);
            holder.name.setText(info.userName);
            holder.icon.setImageDrawable(UserUtil.getUserRoundIcon(getResources(), info.userId));

            holder.inviteState.setVisibility(GONE);
            holder.invite.setVisibility(GONE);

            if (!mShowInvite || !TextUtils.isEmpty(info.userId) &&
                    info.userId.equals(mOwnerId)) return;

            if (mInviteManager != null && mInviteManager.hasInvited(info.userId)) {
                holder.inviteState.setVisibility(VISIBLE);
            } else {
                holder.invite.setVisibility(VISIBLE);
                holder.invite.setOnClickListener(view -> {
                    if (mListener != null) {
                        mListener.onUserInvited(mInviteSeatNo, info.userId, info.userName);
                    }
                });
            }
        }

        @Override
        public int getItemCount() {
            return mList == null ? 0 : mList.size();
        }

        public void reset(List<RoomUserInfo> list) {
            if (list != null) {
                mList.clear();
                mList.addAll(list);
                notifyDataSetChanged();
            }
        }
    }

    private static class UserListViewHolder extends RecyclerView.ViewHolder {
        AppCompatImageView icon;
        AppCompatTextView name;
        AppCompatTextView invite;
        LinearLayout inviteState;

        public UserListViewHolder(@NonNull View itemView) {
            super(itemView);
            icon = itemView.findViewById(R.id.action_sheet_online_user_item_icon);
            name = itemView.findViewById(R.id.action_sheet_online_user_item_name);
            invite = itemView.findViewById(R.id.action_sheet_user_list_invite_btn);
            inviteState = itemView.findViewById(R.id.action_sheet_online_user_inviting_status_layout);
        }
    }

    private class UserApplyAdapter extends RecyclerView.Adapter<UserApplyViewHolder> {
        private List<RoomUserInfo> mList = new ArrayList<>();

        @NonNull
        @Override
        public UserApplyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new UserApplyViewHolder(LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.action_sheet_online_user_apply_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull UserApplyViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            int total = mList.size();
            if (pos >= total) return;
            RoomUserInfo info = mList.get(pos);
            holder.name.setText(info.userName);
            holder.icon.setImageDrawable(UserUtil.getUserRoundIcon(getResources(), info.userId));
            holder.accept.setOnClickListener(view -> {
                if (mListener != null) {
                    mListener.onApplicationAccepted(pos, info.userId, info.userName);
                }
            });
            holder.reject.setOnClickListener(view -> {
                if (mListener != null) {
                    mListener.onApplicationRejected(pos, info.userId, info.userName);
                }
            });
        }

        @Override
        public int getItemCount() {
            return mList == null ? 0 : mList.size();
        }

        public void reset(List<RoomUserInfo> list) {
            if (list != null) {
                mList.clear();
                mList.addAll(list);
                notifyDataSetChanged();
            }
        }
    }

    private static class UserApplyViewHolder extends RecyclerView.ViewHolder {
        AppCompatImageView icon;
        AppCompatTextView name;
        AppCompatTextView accept;
        AppCompatTextView reject;

        public UserApplyViewHolder(@NonNull View itemView) {
            super(itemView);
            icon = itemView.findViewById(R.id.action_sheet_online_user_item_icon);
            name = itemView.findViewById(R.id.action_sheet_online_user_item_name);
            accept = itemView.findViewById(R.id.action_sheet_online_user_item_accept);
            reject = itemView.findViewById(R.id.action_sheet_online_user_item_reject);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.online_user_type_title_layout_left:
                if (mDefaultShowAll) return;
                changeTab();
                break;
            case R.id.online_user_type_title_layout_right:
                if (!mDefaultShowAll) return;
                changeTab();
                break;
        }
    }
}
