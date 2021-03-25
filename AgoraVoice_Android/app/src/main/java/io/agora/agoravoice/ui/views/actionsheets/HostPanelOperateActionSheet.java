package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.agoravoice.R;
import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;
import io.agora.agoravoice.ui.views.ChatRoomHostPanel;

public class HostPanelOperateActionSheet extends AbstractActionSheet {
    public interface HostPanelActionSheetListener {
        void onSeatUnblock(int position);
        void onSeatBlocked(int position);
        void onSeatInvited(int position);
        void onSeatApplied(int position);
        void onSeatMuted(int position, String userId, String userName, boolean muted);
        void onUserLeave(int position, String userId, String userName);
    }

    public static class SeatOps {
        public static final int UNBLOCK = 0;
        public static final int BLOCK = 1;
        public static final int INVITE = 2;
        public static final int APPLY = 3;
        public static final int MUTE = 4;
        public static final int UN_MUTE = 5;
        public static final int FORCE_LEAVE = 6;
        public static final int LEAVE = 7;
    }

    private int mPosition;
    private int mState;

    // The user that has taken this seat, may be null
    private ChatRoomHostPanel.Seat mSeat;

    // The role of current user
    private boolean mIsOwner;
    private boolean mIsHost;

    private String[] mSeatOpTexts;

    private int[] mOpenSeatOwnerOps = { SeatOps.INVITE, SeatOps.BLOCK };
    private int[] mBlockSeatOps = { SeatOps.UNBLOCK };
    private int[] mTakenSeatOwnerOps = { SeatOps.MUTE, SeatOps.FORCE_LEAVE, SeatOps.BLOCK };
    private int[] mTakenSeatHostOps = { SeatOps.LEAVE };
    private int[] mMutedSeatOwnerOps = { SeatOps.UN_MUTE, SeatOps.FORCE_LEAVE, SeatOps.BLOCK };
    private int[] mMutedSeatHostOps = { SeatOps.LEAVE };
    private int[] mAudienceOps = { SeatOps.APPLY };

    private OperateAdapter mAdapter;
    private HostPanelActionSheetListener mListener;

    public HostPanelOperateActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        mSeatOpTexts = getResources().getStringArray(R.array.action_sheet_seat_operations);

        LayoutInflater.from(getContext()).inflate(
                R.layout.action_sheet_seat_operation, this);
        RecyclerView recyclerView = findViewById(R.id.action_sheet_seat_operation_recycler);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext(),
                LinearLayoutManager.VERTICAL, false));
        recyclerView.addItemDecoration(new OperateItemDecoration());
        mAdapter = new OperateAdapter();
        recyclerView.setAdapter(mAdapter);
    }

    public void setSeatPosition(int position) {
        mPosition = position;
    }

    public void setSeatState(int state) {
        mState = state;
    }

    public void setMyRole(boolean isOwner, boolean isHost) {
        mIsOwner = isOwner;
        mIsHost = isHost;
    }

    public void setSeat(ChatRoomHostPanel.Seat seat) {
        mSeat = seat;
    }

    public void setOperationListener(HostPanelActionSheetListener listener) {
        mListener = listener;
    }

    public void notifyChange() {
        mAdapter.notifyDataSetChanged();
    }

    private class OperateAdapter extends RecyclerView.Adapter<OperateViewHolder> {
        @NonNull
        @Override
        public OperateViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new OperateViewHolder(LayoutInflater.from(getContext())
                    .inflate(R.layout.action_sheet_seat_operation_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull OperateViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            int[] opArray = null;
            if (mState == ChatRoomHostPanel.Seat.STATE_OPEN) {
                if (mIsOwner) {
                    opArray = mOpenSeatOwnerOps;
                } else {
                    opArray = mAudienceOps;
                }
            } else if (mState == ChatRoomHostPanel.Seat.STATE_BLOCK) {
                opArray = mBlockSeatOps;
            } else if (mState == ChatRoomHostPanel.Seat.STATE_TAKEN && mSeat != null) {
                boolean hasAudio = mSeat.getStreamInfo() != null && mSeat.getStreamInfo().enableAudio;
                if (mIsOwner) {
                    if (!hasAudio) {
                        opArray = mMutedSeatOwnerOps;
                    } else {
                        opArray = mTakenSeatOwnerOps;
                    }
                } else if (mIsHost) {
                    if (!hasAudio) {
                        opArray = mMutedSeatHostOps;
                    } else {
                        opArray = mTakenSeatHostOps;
                    }
                }
            }

            if (opArray == null) return;
            if (0 <= pos && pos < opArray.length) {
                int op = opArray[pos];
                holder.name.setText(mSeatOpTexts[op]);
                setClickListener(holder.itemView, op);
            }
        }

        private void setClickListener(View view, int op) {
            view.setOnClickListener(v -> {
                if (mListener != null) {
                    if (op == SeatOps.INVITE) {
                        mListener.onSeatInvited(mPosition);
                    } else if (op == SeatOps.BLOCK) {
                        mListener.onSeatBlocked(mPosition);
                    } else if (op == SeatOps.UNBLOCK) {
                        mListener.onSeatUnblock(mPosition);
                    } else if (op == SeatOps.APPLY) {
                        mListener.onSeatApplied(mPosition);
                    } else if (mSeat != null && mSeat.getUser() != null
                            && (mIsOwner || mIsHost)) {
                        String userId = mSeat.getUser().getUserId();
                        String userName = mSeat.getUser().getUserName();
                        if (op == SeatOps.MUTE) {
                            mListener.onSeatMuted(mPosition, userId, userName, true);
                        } else if (op == SeatOps.UN_MUTE) {
                            mListener.onSeatMuted(mPosition, userId, userName, false);
                        } else if (op == SeatOps.FORCE_LEAVE || op == SeatOps.LEAVE) {
                            mListener.onUserLeave(mPosition, userId, userName);
                        }
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            int[] opArray = null;
            if (mState == ChatRoomHostPanel.Seat.STATE_OPEN) {
                if (mIsOwner) {
                    opArray = mOpenSeatOwnerOps;
                } else {
                    opArray = mAudienceOps;
                }
            } else if (mState == ChatRoomHostPanel.Seat.STATE_BLOCK) {
                opArray = mBlockSeatOps;
            } else if (mState == ChatRoomHostPanel.Seat.STATE_TAKEN) {
                RoomStreamInfo info = mSeat.getStreamInfo();
                boolean hasAudio = info != null && info.enableAudio;
                if (mIsOwner) {
                    if (hasAudio) {
                        opArray = mTakenSeatOwnerOps;
                    } else {
                        opArray = mMutedSeatOwnerOps;
                    }
                } else if (mIsHost) {
                    if (hasAudio) {
                        opArray = mTakenSeatHostOps;
                    } else {
                        opArray = mMutedSeatOwnerOps;
                    }
                }
            }

            return opArray == null ? 0 : opArray.length;
        }
    }

    private static class OperateViewHolder extends RecyclerView.ViewHolder {
        AppCompatTextView name;

        public OperateViewHolder(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.action_sheet_seat_operation_name);
        }
    }

    private class OperateItemDecoration extends RecyclerView.ItemDecoration {
        private int mDividerHeight;
        private int mDividerColor = Color.parseColor("#FF0C121B");

        OperateItemDecoration() {
            mDividerHeight = getResources().getDimensionPixelOffset(
                    R.dimen.action_sheet_seat_operation_item_divider_height);
        }

        @Override
        public void onDrawOver(@NonNull Canvas c, @NonNull RecyclerView parent,
                               @NonNull RecyclerView.State state) {
            Rect rect = new Rect();
            Paint paint = new Paint();
            paint.setColor(mDividerColor);

            int count = parent.getChildCount();
            for (int i = 0; i < count; i++) {
                View child = parent.getChildAt(i);
                child.getDrawingRect(rect);
                int startX = rect.left;
                int width = rect.right - rect.left;
                int height = rect.bottom - rect.top;
                int startY = height * (i + 1);
                c.drawRect(new Rect(startX, startY, startX + width,
                        startY + mDividerHeight), paint);
            }
        }
    }
}
