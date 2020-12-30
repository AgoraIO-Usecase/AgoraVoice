package io.agora.agoravoice.manager;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.agora.agoravoice.R;
import io.agora.agoravoice.business.BusinessProxy;
import io.agora.agoravoice.business.BusinessProxyBuilder;
import io.agora.agoravoice.business.BusinessProxyContext;
import io.agora.agoravoice.business.BusinessProxyListener;
import io.agora.agoravoice.business.definition.interfaces.RoomEventListener;
import io.agora.agoravoice.business.definition.interfaces.VoiceCallback;
import io.agora.agoravoice.business.definition.struct.AppVersionInfo;
import io.agora.agoravoice.business.definition.struct.BusinessType;
import io.agora.agoravoice.business.definition.struct.GiftInfo;
import io.agora.agoravoice.business.definition.struct.MusicInfo;
import io.agora.agoravoice.business.server.retrofit.listener.LogServiceListener;
import io.agora.agoravoice.business.server.retrofit.model.responses.RoomListResp;
import io.agora.agoravoice.utils.Const;

public class ProxyManager implements BusinessProxyListener {
    private Context mContext;
    private BusinessProxy mBusinessProxy;
    private GeneralManager mGeneralManager;
    private UserManager mUserManager;
    private RoomManager mRoomManager;
    private AudioManager mAudioManager;
    private Map<String, InvitationManager> mSeatManagerMap;

    private ArrayList<GeneralServiceListener> mGeneralServiceListeners;
    private ArrayList<UserServiceListener> mUserServiceListeners;
    private ArrayList<RoomServiceListener> mRoomServiceListeners;
    private ArrayList<NetworkStateChangedListener> mNetworkStateListeners;
    private ArrayList<SeatListener> mSeatListeners;

    private NetworkStateReceiver mNetworkStateReceiver;
    private boolean mNetworkConnected;
    private int mNetworkType;

    private boolean mInitialized;

    public interface GeneralServiceListener {
        void onCheckVersionSuccess(AppVersionInfo info);
        void onMusicList(List<MusicInfo> info);
        void onGiftList(List<GiftInfo> info);
        void onGeneralServiceFailed(int type, int code, String message);
    }

    public interface UserServiceListener {
        void onUserCreated(String userId, String userName);
        void onEditUser(String userId, String userName);
        void onLoginSuccess(String userId, String userToken, String rtmToken);
        void onUserServiceFailed(int type, int code, String message);
    }

    public interface RoomServiceListener {
        void onRoomCreated(String roomId, String roomName);
        void onGetRoomList(String nextId, int total, List<RoomListResp.RoomListItem> list);
        void onLeaveRoom();
        void onRoomServiceFailed(int type, int code, String msg);
    }

    public interface NetworkStateChangedListener {
        void onNetworkDisconnected();
        void onNetworkAvailable(int type);
    }

    public interface SeatListener {
        void onSeatBehaviorSuccess(int type, String userId, String userName, int no);
        void onSeatBehaviorFail(int type, String userId, String userName, int no, int code, String message);
        void onSeatStateChanged(int no, int state);
        void onSeatStateChangeFail(int no, int state, int code, String message);
    }

    private class NetworkStateReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            ConnectivityManager cm = (ConnectivityManager) context.
                    getSystemService(Context.CONNECTIVITY_SERVICE);
            if (cm == null) return;

            NetworkInfo info = cm.getActiveNetworkInfo();
            if (info == null || !info.isAvailable() || !info.isConnected()) {
                mNetworkConnected = false;
                for (NetworkStateChangedListener listener : mNetworkStateListeners) {
                    listener.onNetworkDisconnected();
                }
            } else {
                mNetworkConnected = true;
                int type = info.getType();
                if (type != mNetworkType) {
                    mNetworkType = type;
                    for (NetworkStateChangedListener listener : mNetworkStateListeners) {
                        listener.onNetworkAvailable(mNetworkType);
                    }
                }
            }
        }
    }

    public ProxyManager(@NonNull BusinessProxyContext context) {
        mContext = context.getContext();
        mGeneralServiceListeners = new ArrayList<>();
        mUserServiceListeners = new ArrayList<>();
        mRoomServiceListeners = new ArrayList<>();
        mNetworkStateListeners = new ArrayList<>();
        mSeatListeners = new ArrayList<>();
        mSeatManagerMap = new HashMap<>();
        checkNetworkState(mContext);
        registerNetworkStateReceiver();
        mBusinessProxy = BusinessProxyBuilder.create(context, this);
        mGeneralManager = new GeneralManager(mBusinessProxy);
        mUserManager = new UserManager(mBusinessProxy);
        mRoomManager = new RoomManager(mBusinessProxy);
        mAudioManager = new AudioManager(mBusinessProxy);
    }

    public ProxyManager(@NonNull Context context) {
        this(new BusinessProxyContext(context,
                context.getString(R.string.app_id),
                context.getString(R.string.customer_id),
                context.getString(R.string.customer_certificate)));
    }

    private void checkNetworkState(Context context) {
        ConnectivityManager connectivityManager = (ConnectivityManager)
                context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivityManager == null) return;

        NetworkInfo info = connectivityManager
                .getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
        if (info != null && info.isConnected()) {
            mNetworkConnected = true;
            mNetworkType = ConnectivityManager.TYPE_MOBILE;
        } else {
            mNetworkConnected = false;
        }

        info = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        if (info != null && info.isConnected()) {
            mNetworkConnected = true;
            mNetworkType = ConnectivityManager.TYPE_WIFI;
        } else {
            mNetworkConnected = false;
        }
    }

    private void registerNetworkStateReceiver() {
        mNetworkStateReceiver = new NetworkStateReceiver();
        IntentFilter filter = new IntentFilter(
                ConnectivityManager.CONNECTIVITY_ACTION);
        mContext.registerReceiver(mNetworkStateReceiver, filter);
    }

    private void unregisterNetworkStateReceiver() {
        mContext.unregisterReceiver(mNetworkStateReceiver);
    }

    public void addGeneralServiceListener(GeneralServiceListener listener) {
        if (!mGeneralServiceListeners.contains(listener)) {
            mGeneralServiceListeners.add(listener);
        }
    }

    public void removeGeneralServiceListener(GeneralServiceListener listener) {
        mGeneralServiceListeners.remove(listener);
    }

    public void addUserServiceListener(UserServiceListener listener) {
        if (!mUserServiceListeners.contains(listener)) {
            mUserServiceListeners.add(listener);
        }
    }

    public void removeUserServiceListener(UserServiceListener listener) {
        mUserServiceListeners.remove(listener);
    }

    public void addRoomServiceListener(RoomServiceListener listener) {
        if (!mRoomServiceListeners.contains(listener)) {
            mRoomServiceListeners.add(listener);
        }
    }

    public void removeRoomServiceListener(RoomServiceListener listener) {
        mRoomServiceListeners.remove(listener);
    }

    public void addNetworkStateListener(NetworkStateChangedListener listener) {
        if (!mNetworkStateListeners.contains(listener)) {
            mNetworkStateListeners.add(listener);
        }
    }

    public void removeNetworkStateListener(NetworkStateChangedListener listener) {
        mNetworkStateListeners.remove(listener);
    }

    public void addSeatListener(SeatListener listener) {
        if (!mSeatListeners.contains(listener)) {
            mSeatListeners.add(listener);
        }
    }

    public void removeSeatListener(SeatListener listener) {
        mSeatListeners.remove(listener);
    }

    public void checkVersion(String version) {
        mGeneralManager.checkVersion(version);
    }

    public void uploadLogs(LogServiceListener listener) {
        mGeneralManager.uploadLogs(listener);
    }

    public void getMusicList() {
        mGeneralManager.getMusicList();
    }

    public void createUser(String userName) {
        mUserManager.createUser(userName);
    }

    public void editUser(String token, String userId, String userName) {
        mUserManager.editUser(token, userId, userName);
    }

    public void login(String userId) {
        mUserManager.login(userId);
    }

    public void createRoom(String token, String roomName, String image, int duration, int maxNum) {
        mRoomManager.createRoom(token, roomName, image, duration, maxNum);
    }

    public void getRoomList(String token, String nextId, int count, int type) {
        mRoomManager.getRoomList(token, nextId, count, type);
    }

    public void enterRoom(String token, String roomId, String roomName, String userId,
                          String userName, RoomEventListener listener) {
        mRoomManager.enterRoom(token, roomId, roomName, userId, userName, listener);
    }

    public void leaveRoom(String token, String roomId, String userId) {
        mRoomManager.leaveRoom(token, roomId, userId);
    }

    public void destroyRoom(String token, String roomId) {
        mRoomManager.destroyRoom(token, roomId);
    }

    public void sendGift(@NonNull String token, @NonNull String roomId,
                         @NonNull String giftId, int count) {
        mRoomManager.sendGift(token, roomId, giftId, count);
    }

    public void modifyRoom(@NonNull String token, @NonNull String roomId, String backgroundId) {
        mRoomManager.modifyRoom(token, roomId, backgroundId);
    }

    public void sendChatMessage(@NonNull String token, @NonNull String appId,
                                @NonNull String roomId, @NonNull String message) {
        mRoomManager.sendChatMessage(token, appId, roomId, message);
    }

    public void createSeatManager(String roomId) {
        if (!mSeatManagerMap.containsKey(roomId)) {
            mSeatManagerMap.remove(roomId);
        }

        InvitationManager manager = new InvitationManager(roomId, mBusinessProxy);
        mSeatManagerMap.put(roomId, manager);
    }

    public void removeSeatManager(String roomId) {
        mSeatManagerMap.remove(roomId);
    }

    public int requestSeatBehavior(String token, String roomId, String userId, String userName, int no, int type) {
        InvitationManager manager = getRoomInvitationManager(roomId);
        if (manager != null) {
            return manager.requestSeatBehavior(token, userId, userName, no, type);
        }

        return Const.ERR_NOT_INITIALIZED;
    }

    public InvitationManager getRoomInvitationManager(String roomId) {
        return mSeatManagerMap.get(roomId);
    }

    public void changeSeatState(String token, String roomId, int no, int state) {
        InvitationManager manager = mSeatManagerMap.get(roomId);
        if (manager != null) manager.requestSeatStateChange(token, roomId, no, state);
    }

    @Override
    public void onCheckVersionSuccess(AppVersionInfo info) {
        for (GeneralServiceListener listener : mGeneralServiceListeners) {
            listener.onCheckVersionSuccess(info);
        }
    }

    @Override
    public void onGetMustList(List<MusicInfo> info) {
        for (GeneralServiceListener listener : mGeneralServiceListeners) {
            listener.onMusicList(info);
        }
    }

    @Override
    public void onGetGiftList(List<GiftInfo> info) {
        for (GeneralServiceListener listener : mGeneralServiceListeners) {
            listener.onGiftList(info);
        }
    }

    @Override
    public void onCreateUser(String userId, String userName) {
        for (UserServiceListener listener : mUserServiceListeners) {
            listener.onUserCreated(userId, userName);
        }
    }

    @Override
    public void onEditUserSuccess(String userId, String userName) {
        for (UserServiceListener listener : mUserServiceListeners) {
            listener.onEditUser(userId, userName);
        }
    }

    @Override
    public void onLoginSuccess(String userId, String userToken, String rtmToken) {
        for (UserServiceListener listener : mUserServiceListeners) {
            listener.onLoginSuccess(userId, userToken, rtmToken);
        }
    }

    @Override
    public void onRoomCreated(String roomId, String roomName) {
        for (RoomServiceListener listener : mRoomServiceListeners) {
            listener.onRoomCreated(roomId, roomName);
        }
    }

    @Override
    public void onLeaveRoom() {
        for (RoomServiceListener listener : mRoomServiceListeners) {
            listener.onLeaveRoom();
        }
    }

    @Override
    public void onGetRoomList(String nextId, int total, List<RoomListResp.RoomListItem> list) {
        for (RoomServiceListener listener : mRoomServiceListeners) {
            listener.onGetRoomList(nextId, total, list);
        }
    }

    @Override
    public void onSeatBehaviorSuccess(int type, String userId, String userName, int no) {
        for (SeatListener listener : mSeatListeners) {
            listener.onSeatBehaviorSuccess(type, userId, userName, no);
        }
    }

    @Override
    public void onSeatBehaviorFail(int type, String userId, String userName, int no, int code, String msg) {
        for (SeatListener listener : mSeatListeners) {
            listener.onSeatBehaviorFail(type, userId, userName, no, code, msg);
        }
    }

    @Override
    public void onSeatStateChanged(int no, int state) {
        for (SeatListener listener : mSeatListeners) {
            listener.onSeatStateChanged(no, state);
        }
    }

    @Override
    public void onSeatStateChangeFail(int no, int state, int code, String msg) {
        for (SeatListener listener : mSeatListeners) {
            listener.onSeatStateChangeFail(no, state, code, msg);
        }
    }

    @Override
    public void onBusinessFail(int type, int code, String message) {
        switch (type) {
            case BusinessType.CHECK_VERSION:
            case BusinessType.MUSIC_LIST:
            case BusinessType.GIFT_LIST:
                for (GeneralServiceListener listener : mGeneralServiceListeners) {
                    listener.onGeneralServiceFailed(type, code, message);
                }
                break;
            case BusinessType.LOGIN:
            case BusinessType.CREATE_USER:
                for (UserServiceListener listener : mUserServiceListeners) {
                    listener.onUserServiceFailed(type, code, message);
                }
                break;
            case BusinessType.CREATE_ROOM:
            case BusinessType.LEAVE_ROOM:
                for (RoomServiceListener listener : mRoomServiceListeners) {
                    listener.onRoomServiceFailed(type, code, message);
                }
                break;
        }
    }

    public AudioManager getAudioManager() {
        return mAudioManager;
    }

    public String getServiceVersion() {
        return mBusinessProxy.getServiceVersion();
    }

    public void logout() {
        mBusinessProxy.logout();
    }

    public void release() {
        unregisterNetworkStateReceiver();
        mGeneralServiceListeners.clear();
        mUserServiceListeners.clear();
        mRoomServiceListeners.clear();
        mNetworkStateListeners.clear();
    }
}
