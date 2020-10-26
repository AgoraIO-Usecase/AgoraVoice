package io.agora.agoravoice.manager;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.agora.agoravoice.business.BusinessProxy;
import io.agora.agoravoice.business.definition.struct.ErrorCode;
import io.agora.agoravoice.business.definition.struct.RoomUserInfo;
import io.agora.agoravoice.business.server.retrofit.model.requests.SeatBehavior;
import io.agora.agoravoice.utils.Const;

public class InvitationManager {
    private BusinessProxy mProxy;
    private String mRoomId;

    private List<RoomUserInfo> mFullUserList = new ArrayList<>();
    private List<RoomUserInfo> mInviteList = new ArrayList<>();
    private Map<String, RoomUserInfo> mInviteMap = new HashMap<>();

    private List<RoomUserInfo> mApplyList = new ArrayList<>();
    private Map<String, RoomUserInfo> mApplyMap = new HashMap<>();
    private Map<String, Integer> mApplySeatMap = new HashMap<>();

    public InvitationManager(@NonNull String roomId, @NonNull BusinessProxy proxy) {
        mRoomId = roomId;
        mProxy = proxy;
    }

    public void updateUserList(List<RoomUserInfo> list) {
        if (list == null || list.size() <= 0) return;
        mFullUserList.clear();
        mFullUserList.addAll(list);
    }

    public List<RoomUserInfo> getFullUserList() {
        return mFullUserList;
    }

    public List<RoomUserInfo> getInvitedList() {
        return mInviteList;
    }

    public boolean hasInvited(String userId) {
        return mInviteMap.containsKey(userId);
    }

    public List<RoomUserInfo> getApplicationList() {
        return mApplyList;
    }

    public boolean hasUserApplied(String userId) {
        return mApplyMap.containsKey(userId);
    }

    public int requestSeatBehavior(@NonNull String token, @NonNull String userId,
                                   String userName, int no, int behavior) {
        int seatNo = no;
        if (behavior == SeatBehavior.INVITE) {
            if (mInviteMap.containsKey(userId)) {
                return Const.ERR_REPEAT_INVITE;
            } else {
                RoomUserInfo info = getUserInfoByUserId(userId);
                if (info == null) return Const.ERR_USER_UNKNOWN;
                if (!mInviteList.contains(info)) {
                    mInviteList.add(info);
                    mInviteMap.put(userId, info);
                }
            }
        } else if (behavior == SeatBehavior.APPLY_ACCEPT ||
            behavior == SeatBehavior.APPLY_REJECT) {
            Integer seatNum = mApplySeatMap.get(userId);
            seatNo = seatNum != null ? seatNum : 0;
        }

        mProxy.requestSeatBehavior(token, mRoomId, userId, userName, seatNo, behavior);
        return Const.ERR_OK;
    }

    public void handleSeatBehaviorRequestFail(String userId, String userName, int no, int behavior, int errorCode) {
        switch (behavior) {
            case SeatBehavior.INVITE:
                RoomUserInfo info = mInviteMap.remove(userId);
                if (info != null) mInviteList.remove(info);
                break;
            case SeatBehavior.APPLY_ACCEPT:
                if (errorCode == ErrorCode.ERROR_SEAT_TAKEN) {
                    // Room owner has accepted the application of
                    // audience for a seat, but the seat has been
                    // taken by earlier operations.
                    // We remove this application from list.
                    info = mApplyMap.remove(userId);
                    if (info != null) mApplyList.remove(info);
                }
                break;
        }
    }

    public void receiveSeatBehaviorResponse(String userId, String userName, int no, int behavior) {
        switch (behavior) {
            case SeatBehavior.INVITE_ACCEPT:
            case SeatBehavior.INVITE_REJECT:
                RoomUserInfo info = mInviteMap.remove(userId);
                if (info != null) mInviteList.remove(info);
                break;
            case SeatBehavior.APPLY:
                info = mApplyMap.remove(userId);
                if (info != null) {
                    mApplyList.remove(info);
                    mApplyList.add(info);
                    mApplySeatMap.remove(userId);
                    mApplySeatMap.put(userId, no);
                } else {
                    info = getUserInfoByUserId(userId);
                    if (info != null) {
                        mApplyMap.put(userId, info);
                        mApplyList.add(info);
                        mApplySeatMap.put(userId, no);
                    }
                }
                break;
            case SeatBehavior.APPLY_ACCEPT:
            case SeatBehavior.APPLY_REJECT:
                info = mApplyMap.remove(userId);
                if (info != null) mApplyList.remove(info);
                if (info != null) mApplySeatMap.remove(userId);
                break;
        }
    }

    public void userLeft(String userId) {
        RoomUserInfo info = mInviteMap.remove(userId);
        if (info != null) mInviteList.remove(info);

        info = mApplyMap.remove(userId);
        if (info != null) mApplyList.remove(info);

        if (info == null) info = getUserInfoByUserId(userId);
        if (info != null) mFullUserList.remove(info);
    }

    public void requestSeatStateChange(@NonNull String token, @NonNull String roomId, int no, int state) {
        mProxy.changeSeatState(token, roomId, no, state);
    }

    private RoomUserInfo getUserInfoByUserId(String userId) {
        RoomUserInfo ret = null;
        for (RoomUserInfo info : mFullUserList) {
            if (info.userId.equals(userId)) {
                ret = info;
            }
        }

        return ret;
    }
}
