package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.agora.agoravoice.R;
import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;
import io.agora.agoravoice.business.definition.struct.SeatStateData;
import io.agora.agoravoice.business.log.Logging;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.UserUtil;

public class ChatRoomHostPanel extends RelativeLayout {
    private static final String TAG = ChatRoomHostPanel.class.getSimpleName();

    private static final int GRID_COUNT = 4;
    private static final int SEAT_COUNT = 8;

    public interface ChatRoomHostPanelListener {
        void onSeatClicked(int position, @Nullable Seat seat);
        void onSeatUserRemoved(int position, String userId, String userName);
        void onSeatUserTaken(int position, String userId, String userName);
    }

    private AppCompatImageView mOwnerImage;
    private AppCompatTextView mOwnerName;
    private AppCompatImageView mOwnerMute;
    private Const.Role mMyRole;
    private String mMyUserId;
    private String mOwnerUid;

    private SeatAdapter mAdapter;
    private List<Seat> mSeats;

    private Map<String, RoomStreamInfo> mRoomStreamMap;

    private ChatRoomHostPanelListener mListener;

    public ChatRoomHostPanel(Context context) {
        super(context);
        init();
    }

    public ChatRoomHostPanel(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.chat_room_host_panel, this);
        mOwnerImage = findViewById(R.id.chat_room_host_panel_owner_image);
        mOwnerName = findViewById(R.id.chat_room_host_panel_owner_name);
        mOwnerMute = findViewById(R.id.chat_room_host_panel_owner_mute);
        mOwnerMute.setVisibility(GONE);
        RecyclerView seatRecycler = findViewById(R.id.chat_room_host_panel_seat_layout);
        seatRecycler.setLayoutManager(new GridLayoutManager(getContext(), GRID_COUNT));
        mAdapter = new SeatAdapter();
        mRoomStreamMap = new HashMap<>();
        seatRecycler.setAdapter(mAdapter);
        initSeats();
    }

    private void initSeats() {
        mSeats = new ArrayList<>(SEAT_COUNT);
        for (int i = 0; i < SEAT_COUNT; i++) {
            mSeats.add(new Seat(i));
        }
    }

    public void setOwnerUid(String ownerId) {
        mOwnerUid = ownerId;
    }

    public void setOwnerImage(String ownerId) {
        Drawable drawable = UserUtil.getUserRoundIcon(getResources(), ownerId);
        setOwnerImage(drawable);
    }

    public void setOwnerImage(Drawable drawable) {
        mOwnerImage.setImageDrawable(drawable);
    }

    public void setOwnerName(String name) {
        mOwnerName.setText(name);
    }

    public void setOwnerMuted(boolean muted) {
        int visibility = muted ? VISIBLE : GONE;
        mOwnerMute.setVisibility(visibility);
    }

    public void setMyInfo(Const.Role role, String userId) {
        mMyRole = role;
        mMyUserId = userId;
        if (mAdapter != null) mAdapter.notifyDataSetChanged();
    }

    public void refresh() {
        mAdapter.notifyDataSetChanged();
    }

    public RoomStreamInfo getStreamInfo(int index) {
        Seat seat = mSeats.get(index);
        SeatUser user = seat.getUser();
        if (user == null) return null;
        String uid = user.getUserId();
        return mRoomStreamMap.get(uid);
    }

    public void setStreamInfo(String userId, RoomStreamInfo info) {
        mRoomStreamMap.put(userId, info);
    }

    public SeatUser getUserByPosition(int position) {
        if (position < 0 || position >= mSeats.size()) return null;
        return mSeats.get(position).getUser();
    }

    public Seat getSeatByUser(String userId) {
        if (userId == null) return null;
        for (Seat seat : mSeats) {
            SeatUser user = seat.getUser();
            if (user != null && userId.equals(
                    seat.getUser().getUserId())) {
                return seat;
            }
        }

        return null;
    }

    public List<String> getAllUsers() {
        List<String> ids = new ArrayList<>();
        for (Seat seat : mSeats) {
            if (seat.getState() == Seat.STATE_TAKEN && seat.getUser() != null) {
                ids.add(seat.getUser().getUserId());
            }
        }

        return ids;
    }

    public void setPanelListener(ChatRoomHostPanelListener listener) {
        mListener = listener;
    }

    public void updateSeatStates(@Nullable List<SeatStateData> info) {
        if (info == null) return;
        boolean changed = false;
        for (SeatStateData data : info) {
            int pos = data.no - 1;
            int newState = toSeatState(data.state);
            Seat seat = mSeats.get(pos);
            int curState = seat.getState();

            if (newState != curState) {
                changed = true;
                if (newState == Seat.STATE_TAKEN) {
                    if (mListener != null) {
                        mListener.onSeatUserTaken(pos, data.userId, data.userName);
                    }
                    seat.setUser(data.userId, data.userName);
                } else if (curState == Seat.STATE_TAKEN) {
                    if (mListener != null) {
                        mListener.onSeatUserRemoved(pos,
                                seat.getUser() != null ? seat.getUser().getUserId() : null,
                                seat.getUser() != null ? seat.getUser().getUserName() : null);
                    }
                    seat.setUser(null);
                }
                seat.setState(pos, newState);
            }
        }

        if (changed) mAdapter.notifyDataSetChanged();
    }

    private int toSeatState(int state) {
        switch (state) {
            case 0: return Seat.STATE_OPEN;
            case 1: return Seat.STATE_TAKEN;
            case 2: return Seat.STATE_BLOCK;
            default: return 0;
        }
    }

    public boolean hasUserTakenASeat(String userId) {
        if (TextUtils.isEmpty(userId)) return false;
        for (Seat seat : mSeats) {
            if (seat.getUser() != null &&
                userId.equals(seat.getUser().getUserId())) {
                return true;
            }
        }

        return false;
    }

    public Seat getSeat(int position) {
        return 0 <= position && position < mSeats.size() ? mSeats.get(position) : null;
    }

    private class SeatAdapter extends RecyclerView.Adapter<SeatViewHolder> {
        @NonNull
        @Override
        public SeatViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SeatViewHolder(LayoutInflater.from(getContext())
                    .inflate(R.layout.chat_room_host_panel_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull SeatViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            resetSeatState(pos, holder);
        }

        private void resetSeatState(int pos, SeatViewHolder holder) {
            holder.open.setVisibility(GONE);
            holder.lock.setVisibility(GONE);
            holder.avatar.setVisibility(GONE);
            holder.mute.setVisibility(GONE);

            final Seat seat = mSeats.get(pos);
            int state = seat.getState();
            SeatUser user = seat.getUser();
            String userId = user != null ? user.getUserId() : null;

            if (state == Seat.STATE_OPEN) {
                holder.open.setVisibility(VISIBLE);
            } else if (state == Seat.STATE_BLOCK) {
                holder.lock.setVisibility(VISIBLE);
            } else if (state == Seat.STATE_TAKEN) {
                if (user != null) {
                    holder.avatar.setVisibility(VISIBLE);
                    holder.avatar.setImageDrawable(
                            UserUtil.getUserRoundIcon(
                            getResources(), user.getUserId()));
                    String uid = user.getUserId();
                    RoomStreamInfo info = mRoomStreamMap.get(uid);
                    boolean enableAudio = info != null && info.enableAudio;
                    Logging.d("Seat " + (pos + 1) + " user " + user.getUserId() +
                            " audio state " + enableAudio);
                    if (info == null) {
                        Logging.d("Stream info not found for seat " +
                                (pos + 1) + " user id " + user.getUserId());
                    }

                    int visibility = enableAudio ? GONE : VISIBLE;
                    holder.mute.setVisibility(visibility);
                }
            }

            boolean isOwner = mMyRole == Const.Role.owner;
            boolean isMySeat = mMyRole == Const.Role.host &&
                    state == Seat.STATE_TAKEN &&
                    userId != null && userId.equals(mMyUserId);
            boolean canApply = mMyRole == Const.Role.audience &&
                    state == Seat.STATE_OPEN;
            if (isOwner || isMySeat || canApply) {
                holder.itemView.setOnClickListener(view -> {
                    if (mListener != null) {
                        mListener.onSeatClicked(pos, seat);
                    }
                });
            } else {
                holder.itemView.setOnClickListener(null);
            }
        }

        @Override
        public int getItemCount() {
            return SEAT_COUNT;
        }
    }

    private static class SeatViewHolder extends RecyclerView.ViewHolder {
        AppCompatImageView open;
        AppCompatImageView lock;
        AppCompatImageView avatar;
        AppCompatImageView mute;

        public SeatViewHolder(@NonNull View itemView) {
            super(itemView);
            open = itemView.findViewById(R.id.seat_state_open);
            lock = itemView.findViewById(R.id.seat_state_lock);
            avatar = itemView.findViewById(R.id.seat_user_avatar);
            mute = itemView.findViewById(R.id.seat_user_mute);
        }
    }

    public class Seat {
        public static final int STATE_OPEN = 0;
        public static final int STATE_TAKEN = 1;
        public static final int STATE_BLOCK = 2;

        private int mState;
        private int mPosition;
        private SeatUser mUser;

        Seat(int position) {
            mState = STATE_OPEN;
            mPosition = position;
        }

        public int getState() {
            return mState;
        }

        public void setState(int position, int state) {
            int s = state;
            if (s < STATE_OPEN || s > STATE_BLOCK) {
                s = STATE_OPEN;
            }
            mState = s;
        }

        public int getPosition() {
            return mPosition;
        }

        public @Nullable SeatUser getUser() {
            return mUser;
        }

        public void setUser(String userId, String userName) {
            mUser = new SeatUser(userId, userName);
        }

        public void setUser(SeatUser user) {
            mUser = user;
        }

        public RoomStreamInfo getStreamInfo() {
            if (mUser == null) return null;
            String uid = mUser.getUserId();
            return uid == null ? null : mRoomStreamMap.get(uid);
        }
    }

    public static class SeatUser {
        private String mUserId;
        private String mUserName;

        public SeatUser(String userId, String userName) {
            mUserId = userId;
            mUserName = userName;
        }

        public String getUserId() {
            return mUserId;
        }

        public String getUserName() {
            return mUserName;
        }
    }

    public void updateMuteState(RoomStreamInfo myStreamInfo, boolean localAudioMuted,
                                @Nullable Map<String, RoomStreamInfo> updatedStreams,
                                @Nullable Map<String, RoomStreamInfo> addedStreams,
                                @Nullable Map<String, RoomStreamInfo> removedStreams) {
        // Note, the stream info only contains remote streams
        updateOwnerMuteState(localAudioMuted, updatedStreams, addedStreams, removedStreams);
        updateHostMuteState(myStreamInfo, localAudioMuted, updatedStreams, addedStreams, removedStreams);
    }

    private void updateOwnerMuteState(boolean localAudioMuted,
                                      @Nullable Map<String, RoomStreamInfo> updatedStreams,
                                      @Nullable Map<String, RoomStreamInfo> addedStreams,
                                      @Nullable Map<String, RoomStreamInfo> removedStreams) {
        boolean enabled = false;
        boolean involved = true;
        if (mMyRole == Const.Role.owner) {
            enabled = !localAudioMuted;
            involved = true;
        } else if (updatedStreams != null && updatedStreams.containsKey(mOwnerUid)) {
            RoomStreamInfo info = updatedStreams.get(mOwnerUid);
            enabled = info != null && info.enableAudio;
        } else if (addedStreams != null && addedStreams.containsKey(mOwnerUid)) {
            RoomStreamInfo info = addedStreams.get(mOwnerUid);
            enabled = info.enableAudio;
        } else if (removedStreams != null && removedStreams.containsKey(mOwnerUid)) {
            enabled = false;
        } else {
            involved = false;
        }

        // If this update event has no info of the owner, nothing will be done.
        if (involved) mOwnerMute.setVisibility(enabled ? GONE : VISIBLE);
    }

    private void updateHostMuteState(RoomStreamInfo myStreamInfo, boolean localAudioMuted,
                                     @Nullable Map<String, RoomStreamInfo> updatedStreams,
                                     @Nullable Map<String, RoomStreamInfo> addedStreams,
                                     @Nullable Map<String, RoomStreamInfo> removedStreams) {

        if (mRoomStreamMap.containsKey(mMyUserId)) {
            RoomStreamInfo info = mRoomStreamMap.get(mMyUserId);
            if (info != null) {
                boolean enabled;
                if (myStreamInfo == null) {
                    enabled = !localAudioMuted;
                    Logging.d("no local stream info found, take local audio " +
                            "setting as default " + enabled);
                } else {
                    info.enableAudio(myStreamInfo.enableAudio);
                    Logging.d("Local stream info found, audio state reset to " + info.enableAudio);
                    enabled = info.enableAudio;
                }

                info.enableAudio(enabled);
            } else if (myStreamInfo != null) {
                Logging.d("Local stream info found, cached local audio state " + info.enableAudio);
                mRoomStreamMap.put(mMyUserId, myStreamInfo);
            } else {
                Logging.d("No cached local stream info");
            }
        }

        if (addedStreams != null) mRoomStreamMap.putAll(addedStreams);

        if (removedStreams != null) {
            for (String id : removedStreams.keySet()) {
                mRoomStreamMap.remove(id);
            }
        }

        if (updatedStreams != null) {
            for (Map.Entry<String, RoomStreamInfo> entry : updatedStreams.entrySet()) {
                String key =  entry.getKey();
                RoomStreamInfo info = entry.getValue();
                mRoomStreamMap.remove(key);
                mRoomStreamMap.put(key, RoomStreamInfo.copy(info));
                Logging.d("updateHostMuteState updated streams " +
                        info.userId + " " + info.enableAudio) ;
            }
        }

        mAdapter.notifyDataSetChanged();
    }
}
