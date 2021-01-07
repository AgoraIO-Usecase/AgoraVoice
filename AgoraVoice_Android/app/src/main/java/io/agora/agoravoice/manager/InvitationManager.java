package io.agora.agoravoice.manager;

import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import io.agora.agoravoice.business.BusinessProxy;
import io.agora.agoravoice.business.definition.struct.ErrorCode;
import io.agora.agoravoice.business.definition.struct.RoomUserInfo;
import io.agora.agoravoice.business.server.retrofit.model.requests.SeatBehavior;
import io.agora.agoravoice.utils.Const;

public class InvitationManager {
    private static final String TAG = InvitationManager.class.getSimpleName();

    public interface InvitationManagerListener {
        void onInvitationTimeout(String userId);

        void onApplicationTimeout(String userId);
    }

    private static final int TIMEOUT = 30 * 1000;

    private final BusinessProxy mProxy;
    private final String mRoomId;

    private final List<InvitationManagerListener> mListener = new ArrayList<>();

    private final List<RoomUserInfo> mFullUserList = new ArrayList<>();

    private final List<RoomUserInfo> mInviteList = new ArrayList<>();
    private final Map<String, RoomUserInfo> mInviteUserInfoMap = new ConcurrentHashMap<>();
    private final Map<String, Integer> mInviteSeatMap = new ConcurrentHashMap<>();
    private final Map<String, Long> mInviteTimeMap = new ConcurrentHashMap<>();

    private final List<RoomUserInfo> mApplyList = new ArrayList<>();
    private final Map<String, RoomUserInfo> mApplyUserInfoMap = new ConcurrentHashMap<>();
    private final Map<String, Integer> mApplySeatMap = new ConcurrentHashMap<>();
    private final Map<String, Long> mApplyTimeMap = new ConcurrentHashMap<>();

    private final Object mInviteLock = new Object();
    private boolean mInviteTimerStop;
    private final Object mApplyLock = new Object();
    private boolean mApplyTimerStop;

    private final Runnable mInviteTimer = () -> {
        synchronized (mInviteLock) {
            while (!mInviteList.isEmpty() && !mInviteTimerStop) {
                Iterator<Map.Entry<String, Long>> iterator
                        = mInviteTimeMap.entrySet().iterator();
                List<String> timeoutUserList = new ArrayList<>();
                while (iterator.hasNext()) {
                    Map.Entry<String, Long> entry = iterator.next();
                    String userId = entry.getKey();
                    long timestamp = entry.getValue();
                    long now = System.currentTimeMillis();
                    if (now - timestamp > TIMEOUT) {
                        timeoutUserList.add(userId);
                    }
                }

                for (String userId : timeoutUserList) {
                    removeInvitationInfo(userId);
                    for (InvitationManagerListener listener : mListener) {
                        listener.onInvitationTimeout(userId);
                    }
                }

                try {
                    mInviteLock.wait(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                    break;
                }
            }
        }
        Log.d(TAG, "invitation timer stops");
    };

    private final Runnable mApplyTimer = () -> {
        synchronized (mApplyLock) {
            while (!mApplyList.isEmpty() && !mApplyTimerStop) {
                Iterator<Map.Entry<String, Long>> iterator =
                        mApplyTimeMap.entrySet().iterator();
                List<String> timeoutUserList = new ArrayList<>();
                while (iterator.hasNext()) {
                    Map.Entry<String, Long> entry = iterator.next();
                    String userId = entry.getKey();
                    long timestamp = entry.getValue();
                    long now = System.currentTimeMillis();
                    if (now - timestamp > TIMEOUT) {
                        timeoutUserList.add(userId);
                    }
                }

                for (String userId : timeoutUserList) {
                    removeApplicationInfo(userId);
                    for (InvitationManagerListener listener : mListener) {
                        listener.onApplicationTimeout(userId);
                    }
                }

                try {
                    mApplyLock.wait(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                    break;
                }
            }
        }

        Log.d(TAG, "application timer stops");
    };

    private void startInviteTimer() {
        mInviteTimerStop = false;
        new Thread(mInviteTimer).start();
    }

    private void startApplyTimer() {
        mApplyTimerStop = false;
        new Thread(mApplyTimer).start();
    }

    private void stopInviteTimer() {
        mInviteTimerStop = true;
    }

    private void stopApplyTimer() {
        mApplyTimerStop = true;
    }

    public void addInvitationListener(InvitationManagerListener listener) {
        mListener.add(listener);
    }

    public void removeInvitationListener(InvitationManagerListener listener) {
        mListener.remove(listener);
    }

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
        return mInviteUserInfoMap.containsKey(userId);
    }

    public List<RoomUserInfo> getApplicationList() {
        return mApplyList;
    }

    public boolean hasApplication() {
        return !mApplyList.isEmpty();
    }

    public boolean hasUserApplied(String userId) {
        return mApplyUserInfoMap.containsKey(userId);
    }

    private void removeInvitationInfo(String userId) {
        mInviteSeatMap.remove(userId);
        mInviteTimeMap.remove(userId);
        RoomUserInfo info = mInviteUserInfoMap.remove(userId);
        if (info != null) mInviteList.remove(info);
    }

    private void removeApplicationInfo(String userId) {
        mApplySeatMap.remove(userId);
        mApplyTimeMap.remove(userId);
        RoomUserInfo info = mApplyUserInfoMap.remove(userId);
        if (info != null) mApplyList.remove(info);
    }

    public int requestSeatBehavior(@NonNull String token, @NonNull String userId,
                                   String userName, int no, int behavior) {
        int seatNo = no;
        if (behavior == SeatBehavior.INVITE) {
            if (mInviteUserInfoMap.containsKey(userId)) {
                return Const.ERR_REPEAT_INVITE;
            } else {
                RoomUserInfo info = getUserInfoByUserId(userId);
                if (info == null) return Const.ERR_USER_UNKNOWN;
                if (!mInviteList.contains(info)) {
                    if (mInviteList.isEmpty()) {
                        // When this is the first in list, start a timer
                        // to check invitation timeout
                        Log.d(TAG, "start invitation timer");
                        startInviteTimer();
                    }

                    mInviteList.add(info);
                    mInviteUserInfoMap.put(userId, info);
                    mInviteSeatMap.put(userId, no);
                    mInviteTimeMap.put(userId, System.currentTimeMillis());
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
                removeInvitationInfo(userId);
                break;
            case SeatBehavior.APPLY_ACCEPT:
                if (errorCode == ErrorCode.ERROR_SEAT_TAKEN) {
                    // Room owner has accepted the application of
                    // audience for a seat, but the seat has been
                    // taken by earlier operations.
                    // We remove this application from list.
                    removeApplicationInfo(userId);
                }
                break;
        }
    }

    public void receiveSeatBehaviorResponse(String userId, String userName, int no, int behavior) {
        switch (behavior) {
            case SeatBehavior.INVITE_ACCEPT:
            case SeatBehavior.INVITE_REJECT:
                RoomUserInfo info = mInviteUserInfoMap.remove(userId);
                if (info != null) mInviteList.remove(info);
                break;
            case SeatBehavior.APPLY:
                info = mApplyUserInfoMap.remove(userId);
                if (info != null) {
                    mApplyList.remove(info);
                    mApplyList.add(info);
                    mApplySeatMap.remove(userId);
                    mApplySeatMap.put(userId, no);
                } else {
                    info = getUserInfoByUserId(userId);
                    if (info != null) {
                        if (mApplyList.isEmpty()) {
                            Log.d(TAG, "start application timer");
                            startApplyTimer();
                        }

                        mApplyList.add(info);
                        mApplyUserInfoMap.put(userId, info);
                        mApplySeatMap.put(userId, no);
                        mApplyTimeMap.put(userId, System.currentTimeMillis());
                    }
                }
                break;
            case SeatBehavior.APPLY_ACCEPT:
            case SeatBehavior.APPLY_REJECT:
                removeApplicationInfo(userId);
                break;
        }
    }

    public void userLeft(String userId) {
        removeInvitationInfo(userId);
        removeApplicationInfo(userId);

        RoomUserInfo info = getUserInfoByUserId(userId);
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
