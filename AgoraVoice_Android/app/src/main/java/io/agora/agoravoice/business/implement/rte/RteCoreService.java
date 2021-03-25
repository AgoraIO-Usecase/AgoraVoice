package io.agora.agoravoice.business.implement.rte;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.google.gson.internal.LinkedTreeMap;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

import io.agora.agoravoice.business.definition.interfaces.*;
import io.agora.agoravoice.business.definition.struct.GiftSendInfo;
import io.agora.agoravoice.business.definition.struct.InvitationMessage;
import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;
import io.agora.agoravoice.business.definition.struct.RoomUserInfo;
import io.agora.agoravoice.business.definition.struct.SeatStateData;
import io.agora.agoravoice.business.implement.AudioEffect;
import io.agora.agoravoice.business.log.Logging;
import io.agora.agoravoice.business.server.retrofit.model.requests.SeatBehavior;
import io.agora.agoravoice.utils.Const;
import io.agora.rte.AgoraRteAudioEncoderConfig;
import io.agora.rte.AgoraRteAudioProfile;
import io.agora.rte.AgoraRteAudioScenario;
import io.agora.rte.AgoraRteAudioSourceType;
import io.agora.rte.AgoraRteCallback;
import io.agora.rte.AgoraRteChatMsg;
import io.agora.rte.AgoraRteEngine;
import io.agora.rte.AgoraRteEngineConfig;
import io.agora.rte.AgoraRteEngineCreator;
import io.agora.rte.AgoraRteEngineEventListener;
import io.agora.rte.AgoraRteError;
import io.agora.rte.AgoraRteLocalAudioStats;
import io.agora.rte.AgoraRteLocalUser;
import io.agora.rte.AgoraRteLocalUserChannelEventListener;
import io.agora.rte.AgoraRteLocalVideoStats;
import io.agora.rte.AgoraRteMediaPlayer;
import io.agora.rte.AgoraRteMediaStreamType;
import io.agora.rte.AgoraRteMediaTrack;
import io.agora.rte.AgoraRteMessage;
import io.agora.rte.AgoraRteRemoteAudioStats;
import io.agora.rte.AgoraRteRemoteStreamInfo;
import io.agora.rte.AgoraRteRemoteVideoStats;
import io.agora.rte.AgoraRteRtcStats;
import io.agora.rte.AgoraRteScene;
import io.agora.rte.AgoraRteSceneConfig;
import io.agora.rte.AgoraRteSceneConnectionChangeReason;
import io.agora.rte.AgoraRteSceneConnectionState;
import io.agora.rte.AgoraRteSceneEventListener;
import io.agora.rte.AgoraRteSceneJoinOptions;
import io.agora.rte.AgoraRteStreamEvent;
import io.agora.rte.AgoraRteStreamInfo;
import io.agora.rte.AgoraRteUserEvent;
import io.agora.rte.AgoraRteUserInfo;
import io.agora.rte.AgoraRteVideoSourceType;
import io.agora.rte.Logger;
import io.agora.rte.NetworkQuality;
import io.agora.rte.internal.impl.Converter;
import io.agora.rte.internal.sync.cmd.AgoraRteAudioState;
import io.agora.rte.internal.sync.cmd.AgoraRteVideoState;

public class RteCoreService implements CoreService,
        AgoraRteEngineEventListener,
        AgoraRteLocalUserChannelEventListener,
        AgoraRteSceneEventListener {
    private final Object mInstanceLock = new Object();

    private AgoraRteEngine mAgoraRteEngine;
    private AgoraRteScene mAgoraRteScene;
    private AgoraRteLocalUser mLocalUser;

    private final Context mContext;
    private final String mAppId;
    private final String mCertificate;
    private final String mCustomerId;

    private RoomEventListener mRoomEventListener;

    private static class InvitationActions {
        public static final int APPLY = 1;
        public static final int INVITE = 2;
        public static final int ACCEPT = 3;
        public static final int REJECT = 4;
        public static final int CANCEL = 5;
    }

    private static class InvitationProcess {
        public static final int APPLY = 1;
        public static final int INVITE = 2;
    }

    public RteCoreService(Context context, String appId,
                          String certificate, String customerId) {
        mContext = context;
        mAppId = appId;
        mCertificate = certificate;
        mCustomerId = customerId;
    }

    // Set rte engine to rte core service because engine
    // instance is created asynchronously, and cannot set
    // an instance variable in a static method.
    private void setRteEngine(AgoraRteEngine engine) {
        Logging.d("set rtc engine " + engine.toString());
        mAgoraRteEngine = engine;
    }

    @Override
    public void login(String uid, VoiceCallback<Void> callback) {
        // The rte engine is initialized and logs in asynchronously
        // at the same time, so this procedure is arranged in
        // "login" api rather than object initialization to
        // keep consistent with the outside world.
        AgoraRteEngineConfig config = new AgoraRteEngineConfig(
                    mAppId, mCustomerId, mCertificate, uid);

        new AgoraRteEngineCreator(mContext, config,
                new AgoraRteCallback<AgoraRteEngine>() {
                    @Override
                    public void success(AgoraRteEngine engine) {
                        engine.setEngineEventListener(RteCoreService.this);
                        setRteEngine(engine);
                        callback.onSuccess(null);
                    }

                    @Override
                    public void fail(@NonNull AgoraRteError error) {
                        callback.onFailure(error.getCode(), error.getMessage());
                    }
                }).create();
    }

    @Override
    public void logout(VoiceCallback<Void> callback) {
        mAgoraRteEngine.destroy();
        callback.onSuccess(null);
    }

    @Override
    public void enterRoom(String roomId, String roomName, String userId, String userName,
                          String streamId, Const.Role role, RoomEventListener listener) {
        try {
            mAgoraRteScene = mAgoraRteEngine.createAgoraRteScene(new AgoraRteSceneConfig(roomId));
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }

        mAgoraRteScene.setSceneEventListener(this);
        mRoomEventListener = listener;

        // The stream id is optional. When not set, the server will assign
        // a main stream id for the current user.
        AgoraRteSceneJoinOptions joinOptions = new AgoraRteSceneJoinOptions(
                userName, Const.Role.toString(role),
                Converter.INSTANCE.stringToSignedInt(streamId));

        setAudioParametersBeforeJoin();
        mAgoraRteScene.join(joinOptions, new AgoraRteCallback<AgoraRteLocalUser>() {
            @Override
            public void success(AgoraRteLocalUser user) {
                mLocalUser = user;
                mLocalUser.setLocalUserListener(RteCoreService.this);

                if (mRoomEventListener != null) {
                    mRoomEventListener.onJoinSuccess(roomId, roomName, user.getStreamId());
                }
            }

            @Override
            public void fail(@NotNull AgoraRteError error) {
                if (mRoomEventListener != null) {
                    mRoomEventListener.onJoinFail(error.getCode(), error.getMessage());
                }
            }
        });
    }

    private void setAudioParametersBeforeJoin() {
        mAgoraRteEngine.getAgoraRteMediaControl().getAudioMediaTrack()
                .setAudioEncoderConfig(new AgoraRteAudioEncoderConfig(
                        AgoraRteAudioProfile.musicHighQualityStereo,
                        AgoraRteAudioScenario.gameStreaming));
        mAgoraRteScene.setParameters("\"che.audio.morph.earsback\":true");
    }

    @Override
    public void leaveRoom(@NonNull String roomId) {
        synchronized (mInstanceLock) {
            if (mAgoraRteScene != null) {
                mAgoraRteScene.leave();
                mAgoraRteScene.destroy();
                mAgoraRteScene = null;
                mRoomEventListener.onRoomLeaved();
            } else {
                Logging.e("Cannot find rte scene instance when leaving room " + roomId);
            }
        }
    }

    @Override
    public void sendRoomChatMessage(@NonNull String roomId, @NonNull String message) {
        if (mLocalUser != null) {
            AgoraRteUserInfo info = new AgoraRteUserInfo(
                    mLocalUser.getUserId(), mLocalUser.getUserName(),
                    mLocalUser.getRole(), null);
            AgoraRteMessage msg = new AgoraRteMessage(info,
                    message, System.currentTimeMillis());
            mLocalUser.sendSceneMessage(msg, new AgoraRteCallback<Void>() {
                @Override
                public void success(@Nullable Void param) {
                    Logging.i("Send room chat message success, from user " +
                            mLocalUser.getUserName() + " message content " + message);
                }

                @Override
                public void fail(@NotNull AgoraRteError error) {
                    Logging.w("Send room chat message fails code " +
                            error.getCode() + ", error message " + error.getMessage());
                }
            });
        } else {
            Logging.e("Cannot find a local user when sending a chat message " + message);
        }
    }

    @Override
    public void startAudioMixing(String roomId, String filePath) {
        AgoraRteMediaPlayer mediaPlayer = mAgoraRteEngine.getAgoraRteMediaControl().getMediaPlayer();
        mediaPlayer.open(filePath);
        mediaPlayer.start();
    }

    @Override
    public void stopAudioMixing() {
        mAgoraRteEngine.getAgoraRteMediaControl().getMediaPlayer().stop();
    }

    @Override
    public void adjustAudioMixingVolume(int volume) {
        mAgoraRteEngine.getAgoraRteMediaControl().getMediaPlayer().adjustPlayoutVolume(volume);
        mAgoraRteEngine.getAgoraRteMediaControl().getMediaPlayer().adjustPublishVolume(volume);
    }

    @Override
    public void enableInEarMonitoring(boolean enable) {
        if (enable) {
            mAgoraRteEngine.getAgoraRteMediaControl().getAudioMediaTrack().enableLocalPlayback();
        } else {
            mAgoraRteEngine.getAgoraRteMediaControl().getAudioMediaTrack().disableLocalPlayback();
        }
    }

    @Override
    public void enableAudioEffect(int type) {
        if (type < 0 || type >= AudioEffect.AUDIO_EFFECT_PARAMS.length) return;
        AudioEffect.AudioEffectParam param = AudioEffect.AUDIO_EFFECT_PARAMS[type];
        mAgoraRteScene.setParameters(param.toParameter());
    }

    @Override
    public void disableAudioEffect() {
        mAgoraRteScene.setParameters("{\"che.audio.morph.reverb_preset\":0}");
    }

    @Override
    public void set3DHumanVoiceParams(int speed) {
        String format = "{\"che.audio.morph.threedim_voice\":%d}";
        String param = String.format(Locale.getDefault(), format, speed);
        mAgoraRteScene.setParameters(param);
    }

    @Override
    public void setElectronicParams(int key, int value) {
        String format = "{\"che.audio.morph.electronic_voice\":{\"key\":%d,\"value\":%d}}";
        String param = String.format(Locale.getDefault(), format, key, value);
        mAgoraRteScene.setParameters(param);
    }

    @Override
    public void enableLocalAudio() {
        if (mLocalUser == null) return;
        AgoraRteMediaTrack audioTrack = mAgoraRteEngine
                .getAgoraRteMediaControl().getAudioMediaTrack();

        mLocalUser.publishLocalMediaTrack(mLocalUser.getStreamId(), audioTrack, new AgoraRteCallback<Void>() {
            @Override
            public void success(@Nullable Void param) {
                Logging.i("enable local audio success");
            }

            @Override
            public void fail(@NotNull AgoraRteError error) {
                Logging.w("enable local audio fail " +
                        error.getCode() + " " + error.getMessage());
            }
        });
    }

    public void disableLocalAudio() {
        if (mLocalUser == null) return;
        AgoraRteMediaTrack audioTrack = mAgoraRteEngine
                .getAgoraRteMediaControl().getAudioMediaTrack();

        mLocalUser.unPublishLocalMediaTrack(mLocalUser.getStreamId(),
                audioTrack, new AgoraRteCallback<Void>() {
            @Override
            public void success(@Nullable Void param) {
                Logging.w("disable local video success");
            }

            @Override
            public void fail(@NotNull AgoraRteError error) {
                Logging.w("disable local video fails " +
                        error.getCode() + " " + error.getMessage());
            }
        });
    }

    @Override
    public void enableRemoteAudio(String userId) {
        if (mAgoraRteScene != null) {
            boolean found = false;
            for (AgoraRteStreamInfo info : mAgoraRteScene.getAllStreams()) {
                if (userId.equals(info.getOwner().getUserId())) {
                    // If this stream needs to be enabled, its owner may be
                    // an audience and the audio or video source type may
                    // not be initialized.
                    // Since it currently has no video capture, now we need
                    // to reset the audio source to microphone recording.
                    info.setAudioSourceType(AgoraRteAudioSourceType.mic);
                    enableRemoteAudio(info, true);
                    found = true;
                }
            }

            if (!found) {
                Logging.w("enableRemoteAudio cannot find a remote user stream " + userId);
            }
        } else {
            Logging.e("enableRemoteAudio scene not initialized");
        }
    }

    @Override
    public void disableRemoteAudio(String userId) {
        if (mAgoraRteScene != null) {
            boolean found = false;
            for (AgoraRteStreamInfo info : mAgoraRteScene.getAllStreams()) {
                if (userId.equals(info.getOwner().getUserId())) {
                    // Whatever the role of the user is, if we want to disable
                    // the remote audio, we need to reset to audio source to none.
                    info.setAudioSourceType(AgoraRteAudioSourceType.none);
                    enableRemoteAudio(info, false);
                    found = true;
                }
            }

            if (!found) {
                Logging.w("disableRemoteAudio cannot find a remote user stream " + userId);
            }
        } else {
            Logging.e("disableRemoteAudio scene not initialized");
        }
    }

    private void enableRemoteAudio(AgoraRteStreamInfo info, Boolean enabled) {
        if (!TextUtils.isEmpty(info.getStreamId())) {
            if (mLocalUser != null) {
                if (enabled) {
                    AgoraRteRemoteStreamInfo remoteInfo =
                            new AgoraRteRemoteStreamInfo(
                                    info.getStreamId(),
                                    info.getStreamName(),
                                    info.getOwner().getUserId(),
                                    info.getVideoSourceType(),
                                    info.getAudioSourceType(),
                                    AgoraRteVideoState.Disable,
                                    AgoraRteAudioState.Open);
                    mLocalUser.createOrUpdateRemoteStream(remoteInfo, new AgoraRteCallback<Void>() {
                        @Override
                        public void success(@Nullable Void param) {
                            Logging.i("enableRemoteAudio true success");
                        }

                        @Override
                        public void fail(@NotNull AgoraRteError error) {
                            Logging.w("enableRemoteAudio true fail " +
                                    error.getCode() + " " + error.getMessage());
                        }
                    });
                } else {
                    mLocalUser.deleteRemoteStream(info, new AgoraRteCallback<Void>() {
                        @Override
                        public void success(@Nullable Void param) {
                            Logging.i("enableRemoteAudio false success");
                        }

                        @Override
                        public void fail(@NotNull AgoraRteError error) {
                            Logging.w("enableRemoteAudio false fail " +
                                    error.getCode() + " " + error.getMessage());
                        }
                    });
                }
            }
        } else {
            Logging.e("enableRemoteAudio stream id is invalid");
        }
    }

    @Override
    public void muteLocalAudio(boolean muted) {
        if (mLocalUser != null) {
            if (muted) {
                mLocalUser.muteLocalMediaStream(
                        mLocalUser.getStreamId(), AgoraRteMediaStreamType.audio);
            } else {
                mLocalUser.unMuteLocalMediaStream(
                        mLocalUser.getStreamId(), AgoraRteMediaStreamType.audio);
            }
        } else {
            Logging.w("muteLocalAudio local user or the user stream id not found");
        }
    }

    @Override
    public void muteRemoteAudio(String userId, boolean muted) {
        AgoraRteUserInfo userInfo = findUserByUserId(userId);
        if (userInfo == null) {
            Logging.w("mute remote audio, cannot find a user " + userId);
            return;
        }

        AgoraRteStreamInfo streamInfo = findStreamInfoByUserId(userId);
        if (streamInfo == null) {
            Logging.w("mute remote audio, cannot find the stream info of user " + userId);
            return;
        }

        if (mLocalUser != null) {
            AgoraRteAudioState audioState = muted ? AgoraRteAudioState.Off : AgoraRteAudioState.Open;
            AgoraRteRemoteStreamInfo stream = new AgoraRteRemoteStreamInfo(
                    streamInfo.getStreamId(),
                    streamInfo.getStreamName(),
                    userId,
                    streamInfo.getVideoSourceType(),
                    streamInfo.getAudioSourceType(),
                    AgoraRteVideoState.Disable,
                    audioState);
            mLocalUser.createOrUpdateRemoteStream(stream, new AgoraRteCallback<Void>() {
                @Override
                public void success(@Nullable Void aVoid) {

                }

                @Override
                public void fail(@NotNull AgoraRteError agoraRteError) {

                }
            });
        } else {
            Logging.w("mute remote audio local user not found");
        }
    }

    @Override
    public String getCoreServiceVersion() {
        return mAgoraRteEngine == null ? "" : mAgoraRteEngine.version();
    }

    private AgoraRteUserInfo findUserByUserId(@NonNull String userId) {
        if (mAgoraRteScene == null) return null;

        for (AgoraRteUserInfo info : mAgoraRteScene.getAllUsers()) {
            if (userId.equals(info.getUserId())) {
                return info;
            }
        }

        return null;
    }

    private AgoraRteStreamInfo findStreamInfoByUserId(String userId) {
        for (AgoraRteStreamInfo info : mAgoraRteScene.getAllStreams()) {
            if (info.getOwner().getUserId().equals(userId)) {
                return info;
            }
        }
        return null;
    }

    @Override
    public void onPeerMessageReceived(@NotNull AgoraRteMessage message) {
        // Peer messages are defined as engine-scoped, and all peer messages
        // should be treated as not relevant to any scenes.
        // Chat peer text messages, user actions, or other mechanisms using
        // rtm peer messages should be parsed and handled in application
        // layers.
        Logging.d("peer message received " + message.getMessage());
        InvitationMessage invitation = new Gson().fromJson(
                message.getMessage(), InvitationMessage.class);
        if (invitation != null && invitation.cmd == 1) {
            int seat = invitation.data.payload.no;
            int action = invitation.data.action;
            int type = 0;

            if (invitation.data.processUuid == InvitationProcess.APPLY) {
                switch (action) {
                    case InvitationActions.APPLY:
                        type = SeatBehavior.APPLY;
                        break;
                    case InvitationActions.ACCEPT:
                        type = SeatBehavior.APPLY_ACCEPT;
                        break;
                    case InvitationActions.REJECT:
                        type = SeatBehavior.APPLY_REJECT;
                        break;
                }
            } else if (invitation.data.processUuid == InvitationProcess.INVITE) {
                switch (action) {
                    case InvitationActions.INVITE:
                        type = SeatBehavior.INVITE;
                        break;
                    case InvitationActions.ACCEPT:
                        type = SeatBehavior.INVITE_ACCEPT;
                        break;
                    case InvitationActions.REJECT:
                        type = SeatBehavior.INVITE_REJECT;
                        break;
                    case InvitationActions.CANCEL:
                        // When server sends cancel
                        type = SeatBehavior.INVITE_CANCEL;
                        break;
                }
            }

            if (type > 0) {
                mRoomEventListener.onReceiveSeatBehavior(
                        mAgoraRteScene.getSceneInfo().getSceneId(),
                        invitation.data.fromUser.userUuid,
                        invitation.data.fromUser.userName, seat, type);
            } else {
                Logger.INSTANCE.w("Unknown seat behavior action " + message);
            }
        }
    }

    @Override
    public void onLocalUserInfoUpdated(@NotNull AgoraRteUserEvent userEvent) {
        List<RoomUserInfo> list = new ArrayList<>();
        String streamId = userEvent.getUserInfo().getStreamId();
        int uid = 0;
        if (streamId != null) {
            uid = Converter.INSTANCE.stringToSignedInt(
                    Objects.requireNonNull(streamId));
        }

        RoomUserInfo info = new RoomUserInfo(
                userEvent.getUserInfo().getUserId(),
                userEvent.getUserInfo().getUserName(),
                Const.Role.fromString(userEvent.getUserInfo().getRole()),
                uid, streamId);
        list.add(info);
        if (mRoomEventListener != null) {
            mRoomEventListener.onRoomMembersUpdated(list.size(), list);
        }
    }

    @Override
    public void onLocalUserPropertyUpdated(@NotNull AgoraRteUserInfo userInfo, @Nullable String cause) {

    }

    @Override
    public void onLocalStreamAdded(@NotNull AgoraRteStreamEvent streamEvent) {
        Logging.i("onLocalStreamAdded " + streamEvent.getStreamInfo().getOwner().getUserName() +
                " " + streamEvent.getStreamInfo().getStreamId());
        if (mRoomEventListener != null) {
            mRoomEventListener.onStreamAdded(toStreamInfo(streamEvent), null);
        }
    }

    @Override
    public void onLocalStreamUpdated(@NotNull AgoraRteStreamEvent streamEvent) {
        Logging.i("onLocalStreamUpdated " + streamEvent.getStreamInfo().getOwner().getUserName() +
                " " + streamEvent.getStreamInfo().getStreamId());
        if (mRoomEventListener != null) {
            mRoomEventListener.onStreamUpdated(toStreamInfo(streamEvent), null);
        }
    }

    @Override
    public void onLocalStreamRemoved(@NotNull AgoraRteStreamEvent streamEvent) {
        Logging.i("onLocalStreamRemoved " +  streamEvent.getStreamInfo().getOwner().getUserName() +
                " " + streamEvent.getStreamInfo().getStreamId());
        if (mRoomEventListener != null) {
            mRoomEventListener.onStreamRemoved(toStreamInfo(streamEvent), null);
        }
    }

    private RoomStreamInfo toStreamInfo(AgoraRteStreamEvent event) {
        return new RoomStreamInfo(
                event.getStreamInfo().getOwner().getUserId(),
                event.getStreamInfo().getOwner().getUserName(),
                event.getStreamInfo().getStreamId(),
                event.getStreamInfo().getStreamName(),
                event.getStreamInfo().getHasAudio(),
                event.getStreamInfo().getHasVideo(),
                Const.Role.fromString(event.getStreamInfo()
                        .getOwner().getRole()) == Const.Role.owner
        );
    }

    @Override
    public void onLocalAudioStats(@NotNull AgoraRteLocalAudioStats stats) {
        if (mRoomEventListener != null) {
            mRoomEventListener.onLocalAudioStats(stats);
        }
    }

    @Override
    public void onLocalVideoStats(@NotNull AgoraRteLocalVideoStats stats) {
        if (mRoomEventListener != null) {
            mRoomEventListener.onLocalVideoStats(stats);
        }
    }

    private List<RoomUserInfo> toUserListFromAgoraUserList(@NonNull List<? extends AgoraRteUserInfo> userList) {
        List<RoomUserInfo> result = new ArrayList<>();
        for (AgoraRteUserInfo info : userList) {
            result.add(toUserFromAgoraUserInfo(info));
        }

        return result;
    }

    private RoomUserInfo toUserFromAgoraUserInfo(AgoraRteUserInfo info) {
        String streamId = info.getStreamId() != null ? info.getStreamId() : "";

        return new RoomUserInfo(
                info.getUserId(),
                info.getUserName(),
                Const.Role.fromString(info.getRole()),
                Converter.INSTANCE.stringToSignedInt(streamId),
                streamId);
    }

    private RoomStreamInfo toRoomStreamFromAgoraStreamInfo(AgoraRteStreamInfo info) {
        boolean isOwner = Const.Role.fromString(
                info.getOwner().getRole()) == Const.Role.owner;
        return new RoomStreamInfo(
                info.getOwner().getUserId(),
                info.getOwner().getUserName(),
                info.getStreamId(),
                info.getStreamName(),
                info.getHasAudio(),
                info.getHasVideo(),
                isOwner);
    }

    private List<RoomStreamInfo> toRoomStreamListFromAgoraStreams(List<AgoraRteStreamInfo> streamList) {
        List<RoomStreamInfo> result = new ArrayList<>();
        for (AgoraRteStreamInfo info : streamList) {
            result.add(toRoomStreamFromAgoraStreamInfo(info));
        }

        return result;
    }

    private List<RoomStreamInfo> toRoomStreamListFromAgoraStreamEvents(List<AgoraRteStreamEvent> streamEvents) {
        List<RoomStreamInfo> result = new ArrayList<>();
        for (AgoraRteStreamEvent event : streamEvents) {
            result.add(toRoomStreamFromAgoraStreamInfo(event.getStreamInfo()));
        }

        return result;
    }

    @Override
    public void onRemoteUsersInitialized(@NotNull List<? extends AgoraRteUserInfo> users, @NotNull AgoraRteScene scene) {
        List<RoomUserInfo> roomUserList = new ArrayList<>();
        RoomUserInfo owner = null;
        for (AgoraRteUserInfo info : scene.getAllUsers()) {
            RoomUserInfo user = toUserFromAgoraUserInfo(info);
            if (user.role == Const.Role.owner) {
                owner = user;
            }
            roomUserList.add(user);
        }

        List<RoomStreamInfo> streamList = toRoomStreamListFromAgoraStreams(scene.getAllStreams());
        mRoomEventListener.onRoomMembersInitialized(owner, roomUserList.size(), roomUserList, streamList);

        Map<String, Object> properties = scene.getSceneProperties();
        mRoomEventListener.onRoomPropertyUpdated(getBgIdFromProperty(properties),
                getSeatInfo(properties), getGiftRank(properties), null);
    }

    private String getBgIdFromProperty(@Nullable Map<String, Object> map) {
        String id = "-1";
        if (map == null || map.get("basic") == null) return id;

        Object basicMap = map.get("basic");
        if (!(basicMap instanceof Map)) return id;
        Map<?, ?> proMap = (Map<?, ?>) basicMap;

        if (proMap.get("backgroundImage") != null) {
            id = (String) proMap.get("backgroundImage");
        }
        return id;
    }

    private List<SeatStateData> getSeatInfo(@Nullable Map<String, Object> map) {
        if (map == null || map.get("seats") == null) return null;
        Object listObj = map.get("seats");
        if (!(listObj instanceof ArrayList<?>)) return null;

        List<SeatStateData> result = new ArrayList<>();
        ArrayList<?> seatList = (ArrayList<?>) listObj;
        for (Object obj : seatList) {
            if (obj instanceof LinkedTreeMap<?, ?>) {
                LinkedTreeMap<?, ?> seatMap = (LinkedTreeMap<?, ?>) obj;
                Object value = seatMap.get("no");
                int no = (value instanceof Double) ? ((Double) value).intValue(): 0;
                String userId = (String) seatMap.get("userId");
                String userName = (String) seatMap.get("userName");
                value = seatMap.get("state");
                int state = (value instanceof Double) ? ((Double) value).intValue() : 0;
                AgoraRteUserInfo info = findUserByUserId(userId);
                SeatStateData seatStateData = new SeatStateData(no,
                        userId, userName,
                        info != null ? info.getStreamId() : null, state);
                result.add(seatStateData);
            }
        }
        return result;
    }

    private List<GiftSendInfo> getGiftRank(@androidx.annotation.Nullable Map<String, Object> map) {
        if (map == null || map.get("gift") == null) return null;
        Object obj = map.get("gift");
        if (!(obj instanceof Map<?, ?>)) return null;
        obj = ((Map<?, ?>) obj).get("ranks");
        if (!(obj instanceof List<?>)) return null;

        List<?> list = (List<?>) obj;
        List<GiftSendInfo> result = new ArrayList<>();
        for (Object item : list) {
            if (!(item instanceof Map<?, ?>)) break;
            Map<?, ?> itemMap = (Map<?, ?>) item;
            String userId = (String) itemMap.get("userId");
            String userName = (String) itemMap.get("userName");
            String id = (String) itemMap.get("giftId");
            Object value = itemMap.get("rank");
            int rank = (value instanceof Double) ? ((Double) value).intValue() : 0;
            GiftSendInfo info = new GiftSendInfo(userId, userName, id, rank);
            result.add(info);
        }
        return result;
    }

    private GiftSendInfo getGiftSend(@androidx.annotation.Nullable Map<String, Object> map) {
        if (map == null) return null;
        if (!map.containsKey("gift")) return null;
        Object giftObj = map.get("gift");
        if (!(giftObj instanceof Map<?, ?>)) return null;
        Map<?, ?> giftMap = (Map<?, ?>) giftObj;

        String userId = (String) giftMap.get("userId");
        String userName = (String) giftMap.get("userName");
        String id = (String) giftMap.get("giftId");
        return new GiftSendInfo(userId, userName, id, 0);
    }

    @Override
    public void onRemoteUsersJoined(@NotNull List<? extends AgoraRteUserInfo> users, @NotNull AgoraRteScene scene) {
        List<RoomUserInfo> totalList = toUserListFromAgoraUserList(scene.getAllUsers());
        List<RoomUserInfo> joinedList = toUserListFromAgoraUserList(users);
        mRoomEventListener.onRoomMembersJoined(totalList.size(), totalList, joinedList.size(), joinedList);
    }

    private List<RoomUserInfo> toUserListFromAgoraUserEventList(@NonNull List<AgoraRteUserEvent> userEventList) {
        List<RoomUserInfo> result = new ArrayList<>();
        for (AgoraRteUserEvent event : userEventList) {
            result.add(toUserFromAgoraUserInfo(event.getUserInfo()));
        }

        return result;
    }

    @Override
    public void onRemoteUserLeft(@NotNull List<AgoraRteUserEvent> userEvent, @NotNull AgoraRteScene scene) {
        List<RoomUserInfo> totalList = toUserListFromAgoraUserList(scene.getAllUsers());
        List<RoomUserInfo> leftUsers = toUserListFromAgoraUserEventList(userEvent);
        mRoomEventListener.onRoomMembersLeft(totalList.size(), totalList, leftUsers.size(), leftUsers);
    }

    @Override
    public void onSceneMessageReceived(@NotNull AgoraRteMessage message, @NotNull AgoraRteScene scene) {
        mRoomEventListener.onChatMessageReceive(message.getFromUser().getUserId(),
                message.getFromUser().getUserName(), message.getMessage());
    }

    @Override
    public void onSceneChatMessageReceived(@NotNull AgoraRteChatMsg chatMsg, @NotNull AgoraRteScene scene) {
        mRoomEventListener.onChatMessageReceive(chatMsg.getFromUser().getUserUuid(),
                chatMsg.getFromUser().getUserName(), chatMsg.getMessage());
    }

    @Override
    public void onRemoteStreamsInitialized(@NotNull List<AgoraRteStreamInfo> streams, @NotNull AgoraRteScene scene) {
        for (AgoraRteStreamInfo stream : streams) {
            handleRemoteStreamSubscription(stream);
        }

        mRoomEventListener.onStreamInitialized(null, toRoomStreamListFromAgoraStreams(streams));
    }

    private void handleRemoteStreamSubscription(AgoraRteStreamInfo stream) {
        if (stream.getAudioSourceType() != AgoraRteAudioSourceType.none) {
            if (stream.getHasAudio()) mLocalUser.subscribeRemoteStream(stream.getStreamId(), AgoraRteMediaStreamType.audio);
            else mLocalUser.unsubscribeRemoteStream(stream.getStreamId(), AgoraRteMediaStreamType.audio);
        }

        if (stream.getVideoSourceType() != AgoraRteVideoSourceType.none) {
            if (stream.getHasVideo()) mLocalUser.subscribeRemoteStream(stream.getStreamId(), AgoraRteMediaStreamType.video);
            else mLocalUser.unsubscribeRemoteStream(stream.getStreamId(), AgoraRteMediaStreamType.video);
        }
    }

    private RoomStreamInfo findLocalStream(List<AgoraRteStreamEvent> streamEvents) {
        if (mLocalUser == null) return null;

        for (AgoraRteStreamEvent event : streamEvents) {
            if (event.getStreamInfo().getOwner().getUserId()
                    .equals(mLocalUser.getUserId())) {
                return toRoomStreamFromAgoraStreamInfo(event.getStreamInfo());
            }
        }
        return null;
    }

    @Override
    public void onRemoteStreamsAdded(@NotNull List<AgoraRteStreamEvent> streamEvents, @NotNull AgoraRteScene scene) {
        List<RoomStreamInfo> addList = toRoomStreamListFromAgoraStreamEvents(streamEvents);
        RoomStreamInfo localStream = findLocalStream(streamEvents);
        mRoomEventListener.onStreamAdded(localStream, addList);
    }

    @Override
    public void onRemoteStreamUpdated(@NotNull List<AgoraRteStreamEvent> streamEvents, @NotNull AgoraRteScene scene) {
        List<RoomStreamInfo> updateList = toRoomStreamListFromAgoraStreamEvents(streamEvents);
        RoomStreamInfo localStream = findLocalStream(streamEvents);
        mRoomEventListener.onStreamUpdated(localStream, updateList);
    }

    @Override
    public void onRemoteStreamsRemoved(@NotNull List<AgoraRteStreamEvent> streamEvents, @NotNull AgoraRteScene scene) {
        List<RoomStreamInfo> removeList = toRoomStreamListFromAgoraStreamEvents(streamEvents);
        RoomStreamInfo localStream = findLocalStream(streamEvents);
        mRoomEventListener.onStreamRemoved(localStream, removeList);
    }

    @Override
    public void onScenePropertyUpdated(@NotNull AgoraRteScene scene,
                                       @NonNull List<String> changedProperties,
                                       boolean remove, @Nullable Map<String, Object> cause) {
        Map<String, Object> properties = scene.getSceneProperties();
        Map<String, Object> changed = new HashMap<>();
        for (String key : changedProperties) {
            changed.put(key, properties.get(key));
        }

        RoomEndCause roomEnd = getRoomEndCause(cause);
        if (roomEnd != null && roomEnd.cmd == 1) {
            // cmd 1 means room state change
            if (checkSceneEnds(changed)) {
                // check to room state is actually closed
                Logging.i("scene has been ended, cause " + roomEnd.status);
                mRoomEventListener.onRoomEnd(roomEnd.status);
                return;
            }
        }

        mRoomEventListener.onRoomPropertyUpdated(getBgIdFromProperty(changed),
                getSeatInfo(changed), getGiftRank(changed), getGiftSend(cause));

        // Room properties that occur just one time and are
        // not maintained in the room property map
        if (cause != null && !cause.isEmpty()) {
            mRoomEventListener.onRoomPropertyUpdated(cause);
        }
    }

    private RoomEndCause getRoomEndCause(Map<String, Object> cause) {
        if (cause == null || cause.isEmpty()) return null;

        int cmd = 0;
        int status = 0;
        Object obj = cause.get("cmd");
        if (obj instanceof Double) {
            cmd = (int) ((double) obj);
        }

        obj = cause.get("data");
        if (obj instanceof Double) {
            status = (int) ((double) obj);
        }

        return new RoomEndCause(cmd, status);
    }

    private static class RoomEndCause {
        public int cmd;
        public int status;

        RoomEndCause(int cmd, int status) {
            this.cmd = cmd;
            this.status = status;
        }
    }

    private boolean checkSceneEnds(@NonNull Map<String, Object> properties) {
        if (!properties.containsKey("basic")) return false;
        Object basicObj = properties.get("basic");
        if (!(basicObj instanceof Map)) return false;
        Object stateObj = ((Map<String, Object>) basicObj).get("state");
        if (!(stateObj instanceof Double) || (((Double) stateObj)).intValue() != 0) return false;
        return true;
    }

    @Override
    public void onRemoteUserPropertyUpdated(@NotNull AgoraRteUserInfo userInfo,
                                            @NotNull AgoraRteScene scene,
                                            @Nullable String cause) {

    }

    @Override
    public void onRemoteUserInfoUpdated(@NotNull AgoraRteUserEvent agoraRteUserEvent,
                                        @NotNull AgoraRteScene agoraRteScene) {

    }

    @Override
    public void onNetworkQualityChanged(@NotNull NetworkQuality quality,
                                        @NotNull AgoraRteUserInfo user,
                                        @NotNull AgoraRteScene scene) {

    }

    @Override
    public void onConnectionStateChanged(@NotNull AgoraRteSceneConnectionState state,
                                         @Nullable AgoraRteSceneConnectionChangeReason reason,
                                         @NotNull AgoraRteScene scene) {

    }

    @Override
    public void onRemoteVideoStats(@NotNull AgoraRteRemoteVideoStats stats) {
        if (mRoomEventListener != null) {
            mRoomEventListener.onRemoteVideoStats(stats);
        }
    }

    @Override
    public void onRemoteAudioStats(@NotNull AgoraRteRemoteAudioStats stats) {
        if (mRoomEventListener != null) {
            mRoomEventListener.onRemoteAudioStats(stats);
        }
    }

    @Override
    public void onRtcStats(@NotNull AgoraRteRtcStats agoraRteRtcStats) {
        if (mRoomEventListener != null) {
            mRoomEventListener.onRtcStats(agoraRteRtcStats);
        }
    }

    @Override
    public void onCustomPeerMessageReceived(@NotNull String message,
                                            @NotNull AgoraRteUserInfo fromUser) {
    }
}
