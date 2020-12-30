package io.agora.agoravoice.business;

import android.content.Context;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.elvishew.xlog.XLog;

import java.util.List;

import io.agora.agoravoice.BuildConfig;
import io.agora.agoravoice.business.definition.interfaces.CoreService;
import io.agora.agoravoice.business.definition.interfaces.RoomEventListener;
import io.agora.agoravoice.business.definition.interfaces.VoiceCallback;
import io.agora.agoravoice.business.definition.struct.AppVersionInfo;
import io.agora.agoravoice.business.definition.struct.GiftInfo;
import io.agora.agoravoice.business.definition.struct.MusicInfo;
import io.agora.agoravoice.business.log.LogUploader;
import io.agora.agoravoice.business.server.ServerClient;
import io.agora.agoravoice.business.server.retrofit.listener.GeneralServiceListener;
import io.agora.agoravoice.business.server.retrofit.listener.LogServiceListener;
import io.agora.agoravoice.business.server.retrofit.listener.RoomServiceListener;
import io.agora.agoravoice.business.server.retrofit.listener.SeatServiceListener;
import io.agora.agoravoice.business.server.retrofit.listener.UserServiceListener;
import io.agora.agoravoice.business.server.retrofit.model.body.OssBody;
import io.agora.agoravoice.business.server.retrofit.model.requests.Request;
import io.agora.agoravoice.business.server.retrofit.model.responses.RoomListResp;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.UserUtil;

/**
 * Proxy class that the app layer calls for services
 * that provide by the core and third-party APIs
 */
public abstract class BusinessProxy implements
        GeneralServiceListener, UserServiceListener,
        RoomServiceListener, SeatServiceListener {
    private static final String APP_CODE = "ent-voice";
    private static final int OS_TYPE = 2;

    // 1 means android phone app (rather than a pad app)
    private static final int TERMINAL_TYPE = 1;

    private final CoreService mCoreService;

    // Custom services
    private final ServerClient mServerClient;

    private final BusinessProxyListener mProxyListener;

    private final BusinessProxyContext mContext;

    public BusinessProxy(@NonNull BusinessProxyContext context,
                         @NonNull BusinessProxyListener listener) {
        mProxyListener = listener;
        mCoreService = getCoreService(context);
        mServerClient = new ServerClient(context.getAppId());
        mContext = context;
    }

    protected abstract CoreService getCoreService(BusinessProxyContext context);

    public String getServiceVersion() {
        return mCoreService.getCoreServiceVersion();
    }

    public void checkAppVersion(String version) {
        mServerClient.checkVersion(APP_CODE, OS_TYPE, TERMINAL_TYPE, version, this);
    }

    @Override
    public void onAppVersionCheckSuccess(AppVersionInfo info) {
        mProxyListener.onCheckVersionSuccess(info);
    }

    public void uploadLogs(final LogServiceListener listener) {
        String sourcePath = UserUtil.appLogFolderPath(mContext.getContext());
        OssBody body = new OssBody(BuildConfig.VERSION_NAME, Build.DEVICE,
                Build.VERSION.SDK, "ZIP", "Android", "AgoraVoice");
        LogUploader.upload(mServerClient, mContext.getContext(), mContext.getAppId(),
                mServerClient.getBaseUrl(), sourcePath, body, listener);
    }

    public void requestMusicList() {
        mServerClient.musicInfoList(this);
    }

    @Override
    public void onGetMusicList(List<MusicInfo> musicList) {
        mProxyListener.onGetMustList(musicList);
    }

    public void requestGiftList() {
        mServerClient.giftList(this);
    }

    @Override
    public void onGetGiftList(List<GiftInfo> giftList) {
        mProxyListener.onGetGiftList(giftList);
    }

    public void login(String userId) {
        mServerClient.login(userId, this);
    }

    @Override
    public void onLoginSuccess(String userId, String userToken, String rtmToken) {
        if (mCoreService == null) return;

        // We have checked that the current user has been logged in
        // to our server, it's time to log to the core service client
        mCoreService.login(userId, new VoiceCallback<Void>() {
            @Override
            public void onSuccess(Void param) {
                mProxyListener.onLoginSuccess(userId, userToken, rtmToken);
            }

            @Override
            public void onFailure(int code, String reason) {
                handleServiceFail(Request.LOGIN, code, reason);
            }
        });
    }

    @Override
    public void onGeneralServiceFail(int type, int code, String msg) {
        handleServiceFail(type, code, msg);
    }

    public void createUser(String userName) {
        mServerClient.createUser(userName, this);
    }

    @Override
    public void onUserCreateSuccess(String userId, String userName) {
        mProxyListener.onCreateUser(userId, userName);
    }

    public void editUser(String token, String userId, String userName) {
        mServerClient.editUserSuccess(token, userId, userName, this);
    }

    @Override
    public void onUserEditSuccess(String userId, String userName) {
        mProxyListener.onEditUserSuccess(userId, userName);
    }

    @Override
    public void onUserServiceFailed(int type, int code, String msg) {
        handleServiceFail(type, code, msg);
    }

    public void createRoom(String token, String roomName, String image, int duration, int maxNum) {
        mServerClient.createRoom(token, roomName, duration, maxNum, image,this);
    }

    @Override
    public void onRoomCreated(String roomId, String roomName) {
        mProxyListener.onRoomCreated(roomId, roomName);
    }

    public void enterRoom(String token, String roomId, String roomName,
                          String userId, String userName, RoomEventListener listener) {
        mServerClient.join(token, roomId, userId, new UserServiceListener() {
            @Override
            public void onUserCreateSuccess(String userId, String userName) {

            }

            @Override
            public void onUserEditSuccess(String userId, String userName) {

            }

            @Override
            public void onLoginSuccess(String userId, String userToken, String rtmToken) {

            }

            @Override
            public void onJoinSuccess(String userId, String streamId, String role) {
                if (mCoreService != null) {
                    XLog.d("agora voice join success stream id "
                            + streamId + " role " + role);
                    mCoreService.enterRoom(roomId, roomName, userId, userName,
                            streamId, Const.Role.fromString(role), listener);
                }
            }

            @Override
            public void onUserServiceFailed(int type, int code, String msg) {
                XLog.d("agora voice join fail stream id " + code + " " + msg);
            }
        });
    }

    @Override
    public void onJoinSuccess(String userId, String streamId, String role) {
        // Not used
    }

    public void leaveRoom(String token, String roomId, String userId) {
        mServerClient.leaveRoom(token, roomId, userId, this);
    }

    @Override
    public void onLeaveRoom(String roomId) {
        if (mCoreService != null) {
            mCoreService.leaveRoom(roomId);
        }

        mProxyListener.onLeaveRoom();
    }

    public void destroyRoom(String token, String roomId) {
        mServerClient.closeRoom(token, roomId, this);
    }

    public void getRoomList(@NonNull String token, @Nullable String nextId,
                            int count, int type) {
        mServerClient.getRoomList(token, nextId, count, type, this);
    }

    @Override
    public void onGetRoomList(String nextId, int total, List<RoomListResp.RoomListItem> list) {
        mProxyListener.onGetRoomList(nextId,total, list);
    }

    public void requestSeatBehavior(@NonNull String token, @NonNull String roomId,
                                    @NonNull String userId, String userName, int no, int type) {
        mServerClient.requestSeatBehavior(token, roomId, userId, userName, no, type, this);
    }

    @Override
    public void onSeatBehaviorSuccess(String roomId, int type, String userId, String userName,
                                      int no, int reason, String message) {
        mProxyListener.onSeatBehaviorSuccess(type, userId, userName, no);
    }

    @Override
    public void onSeatBehaviorFail(int type, String userId, String userName,
                                   int no, int reason, String message) {
        mProxyListener.onSeatBehaviorFail(type, userId, userName, no, reason, message);
    }

    public void changeSeatState(@NonNull String token, @NonNull String roomId,
                                int no, int state) {
        mServerClient.requestSeatStateChange(token, roomId, no, state, this);
    }

    @Override
    public void onSeatStateChanged(int no, int state) {
        mProxyListener.onSeatStateChanged(no, state);
    }

    @Override
    public void onSeatStateChangeFail(int no, int state, int reason, String message) {
        mProxyListener.onSeatStateChangeFail(no, state, reason, message);
    }

    @Override
    public void onRoomServiceFailed(int type, int code, String msg) {
        handleServiceFail(type, code, msg);
    }

    private void handleServiceFail(int type, int code, String msg) {
        int businessType = Request.toBusinessType(type);
        mProxyListener.onBusinessFail(businessType, code, msg);
    }

    public void sendGift(@NonNull String token, @NonNull String roomId,
                         @NonNull String giftId, int count) {
        mServerClient.sendGift(token, roomId, giftId, count, this);
    }

    public void modifyRoom(@NonNull String token, @NonNull String roomId,
                           String backgroundId) {
        mServerClient.modifyRoom(token, roomId, backgroundId, this);
    }

    public void sendChatMessage(@NonNull String token, @NonNull String appId,
                                @NonNull String roomId, @NonNull String message) {
        mCoreService.sendRoomChatMessage(roomId, message);
    }

    public void startBackgroundMusic(String roomId, String filePath) {
        mCoreService.startAudioMixing(roomId, filePath);
    }

    public void stopBackgroundMusic() {
        mCoreService.stopAudioMixing();
    }

    public void adjustBackgroundMusicVolume(int volume) {
        mCoreService.adjustAudioMixingVolume(volume);
    }

    public void enableInEarMonitoring(boolean enable) {
        mCoreService.enableInEarMonitoring(enable);
    }

    public void enableAudioEffect(int type) {
        mCoreService.enableAudioEffect(type);
    }

    public void disableAudioEffect() {
        mCoreService.disableAudioEffect();
    }

    /**
     * Set the speed for 3D human voice, only takes effect
     * when the 3D human voice effect is enabled.
     * @param speed between 1 ~ 60
     */
    public void set3DHumanVoiceParams(int speed) {
        mCoreService.set3DHumanVoiceParams(speed);
    }

    /**
     * Set params for electronic effect, only takes effect
     * when this sound effect is enabled.
     * @param key
     * @param value
     */
    public void setElectronicParams(int key, int value) {
        mCoreService.setElectronicParams(key, value);
    }

    public void enableLocalAudio() {
        mCoreService.enableLocalAudio();
    }

    public void disableLocalAudio() {
        mCoreService.disableLocalAudio();
    }

    public void enableRemoteAudio(String userId, boolean enabled) {
        if (enabled) {
            mCoreService.enableRemoteAudio(userId);
        } else {
            mCoreService.disableRemoteAudio(userId);
        }
    }

    public void muteLocalAudio(boolean muted) {
        mCoreService.muteLocalAudio(muted);
    }

    public void muteRemoteAudio(String userId, boolean muted) {
        mCoreService.muteRemoteAudio(userId, muted);
    }

    public void logout() {
        mCoreService.logout(new VoiceCallback<Void>() {
            @Override
            public void onSuccess(Void param) {

            }

            @Override
            public void onFailure(int code, String reason) {

            }
        });
    }
}
