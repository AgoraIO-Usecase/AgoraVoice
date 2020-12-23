package io.agora.agoravoice.business.implement.edu;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.elvishew.xlog.XLog;
import com.google.gson.internal.LinkedTreeMap;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.agora.agoravoice.business.definition.interfaces.CoreService;
import io.agora.agoravoice.business.definition.interfaces.RoomEventListener;
import io.agora.agoravoice.business.definition.interfaces.VoidCallback;
import io.agora.agoravoice.business.definition.struct.GiftSendInfo;
import io.agora.agoravoice.business.definition.struct.Log;
import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;
import io.agora.agoravoice.business.definition.struct.RoomUserInfo;
import io.agora.agoravoice.business.definition.struct.SeatStateData;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.UserUtil;
import io.agora.education.api.EduCallback;
import io.agora.education.api.manager.EduManager;
import io.agora.education.api.manager.EduManagerOptions;
import io.agora.education.api.manager.listener.EduManagerEventListener;
import io.agora.education.api.message.EduActionMessage;
import io.agora.education.api.message.EduChatMsg;
import io.agora.education.api.message.EduMsg;
import io.agora.education.api.room.EduRoom;
import io.agora.education.api.room.data.AutoPublishItem;
import io.agora.education.api.room.data.EduLoginOptions;
import io.agora.education.api.room.data.EduRoomInfo;
import io.agora.education.api.room.data.EduRoomState;
import io.agora.education.api.room.data.EduRoomStatus;
import io.agora.education.api.room.data.RoomJoinOptions;
import io.agora.education.api.room.data.RoomMediaOptions;
import io.agora.education.api.room.data.RoomStatusEvent;
import io.agora.education.api.room.data.RoomType;
import io.agora.education.api.room.listener.EduRoomEventListener;
import io.agora.education.api.statistics.ConnectionState;
import io.agora.education.api.statistics.ConnectionStateChangeReason;
import io.agora.education.api.statistics.NetworkQuality;
import io.agora.education.api.stream.data.EduStreamEvent;
import io.agora.education.api.stream.data.EduStreamInfo;
import io.agora.education.api.stream.data.LocalStreamInitOptions;
import io.agora.education.api.stream.data.VideoSourceType;
import io.agora.education.api.user.EduStudent;
import io.agora.education.api.user.EduUser;
import io.agora.education.api.user.data.EduBaseUserInfo;
import io.agora.education.api.user.data.EduUserEvent;
import io.agora.education.api.user.data.EduUserInfo;
import io.agora.education.api.user.data.EduUserRole;
import io.agora.education.api.user.listener.EduUserEventListener;
import io.agora.education.impl.room.EduRoomImpl;
import io.agora.education.impl.stream.EduStreamInfoImpl;
import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcChannel;
import io.agora.rte.RteEngineImpl;
import io.agora.rte.listener.RteStatisticsReportListener;
import kotlin.Unit;

public class EduCoreService implements CoreService {
    private static final String TAG = EduCoreService.class.getSimpleName();

    private interface RoomPeerMessageListener {
        void onUserActionMessageReceived(@NotNull EduActionMessage actionMessage);
    }

    private EduManager mEduManager;
    private Map<String, EduRoom> mEduRoomMap;
    private Map<String, EduStreamInfo> mStreamInfoMap;
    private PeerActionMessageListener mPeerMessageListener;
    private Map<String, EduCoreRoomEventListener> mRoomListeners;

    private static class PeerActionMessageListener implements EduManagerEventListener {
        private Map<String, RoomPeerMessageListener> mListeners;

        PeerActionMessageListener() {
            mListeners = new HashMap<>();
        }

        void registerPeerMessageListener(String roomId, RoomPeerMessageListener listener) {
            if (!mListeners.containsKey(roomId)) {
                mListeners.put(roomId, listener);
            }
        }

        void removePeerMessageListener(String roomId) {
            mListeners.remove(roomId);
        }

        @Override
        public void onUserMessageReceived(@NotNull EduMsg message) {

        }

        @Override
        public void onUserChatMessageReceived(@NotNull EduChatMsg chatMsg) {

        }

        @Override
        public void onUserActionMessageReceived(@NotNull EduActionMessage actionMessage) {
            for (Map.Entry<String, RoomPeerMessageListener> entry : mListeners.entrySet()) {
                entry.getValue().onUserActionMessageReceived(actionMessage);
            }
        }

        @Override
        public void onConnectionStateChanged(@NotNull ConnectionState state, @NotNull ConnectionStateChangeReason reason) {

        }
    }

    public EduCoreService(@NonNull Context context, @NonNull String appId,
                          @Nullable String certificate, @NonNull String customerId,
                          @Nullable String logFileDir, int logLevel) {
        EduManagerOptions options = new EduManagerOptions(context, appId);
        options.setCustomerCertificate(certificate);
        options.setCustomerId(customerId);
        options.setLogFileDir(logFileDir);
        options.setLogLevel(Log.toBusinessLogLevel(logLevel));
        mEduManager = EduManager.init(options);
        mEduRoomMap = new HashMap<>();
        mStreamInfoMap = new HashMap<>();
        mRoomListeners = new HashMap<>();
        mPeerMessageListener = new PeerActionMessageListener();
        mEduManager.setEduManagerEventListener(mPeerMessageListener);
    }

    @Override
    public void login(String uid, VoidCallback callback) {
        mEduManager.login(new EduLoginOptions(uid, 0), new EduCallback<Unit>() {
            @Override
            public void onSuccess(@org.jetbrains.annotations.Nullable Unit res) {
                callback.onSuccess();
            }

            @Override
            public void onFailure(int code, @org.jetbrains.annotations.Nullable String reason) {
                callback.onFailure(code, reason);
            }
        });
    }

    @Override
    public void enterRoom(String roomId, String roomName, String userId,
                          String userName, Const.Role role,
                          @NonNull final RoomEventListener listener) {
        EduRoomStatus status = new EduRoomStatus(
                EduRoomState.INIT, 0, true, 0);
        EduRoomInfo info = EduRoomInfo.Companion.create(
                RoomType.LARGE_CLASS.getValue(), roomId, roomName);

        EduRoom room = new EduRoomImpl(info, status);
        EduCoreRoomEventListener coreListener =
                new EduCoreRoomEventListener(roomId, listener);
        room.setEventListener(coreListener);
        mRoomListeners.put(roomId, coreListener);

        RoomMediaOptions mediaOptions = new RoomMediaOptions();
        mediaOptions.setPublishType(role == Const.Role.owner
                ? AutoPublishItem.AutoPublish
                : AutoPublishItem.NoOperation);

        RoomJoinOptions options = new RoomJoinOptions(
                userId, userName, convertRole(role), mediaOptions);

        // Sound effect acquires this private parameter before
        // every time joining a room
        RteEngineImpl.INSTANCE.setRtcParams("{\"che.audio.morph.earsback\":true}");

        room.joinClassroom(options, new EduCallback<EduStudent>() {
            @Override
            public void onSuccess(@Nullable EduStudent res) {
                listener.onJoinSuccess(roomId, roomName);
                mEduRoomMap.put(roomId, room);
                EduUser user = room.getLocalUser();
                user.setEventListener(coreListener);

                android.util.Log.d(TAG, "join classroom success " + user.getUserInfo().getStreams().size());

                if (user.getUserInfo().getRole() == EduUserRole.TEACHER
                        && user.getUserInfo().getStreams().isEmpty()) {
                    // If no stream is ever created for current teacher (room owner
                    // in this scenario), he will create one and publish it
                    // immediately for him to send media streams.
                    // If there is a logic stream for the teacher, he will use
                    // that stream instead. Obtain the stream in local stream
                    // add/update callbacks.
                    XLog.d("Create stream for user " + user.getUserInfo().getUserUuid() +
                            " stream id " + user.getUserInfo().getStreamUuid());
                    // Teachers will obtain streams that are automatically
                    // created by the sdk for them, because they join the
                    // classroom with natural permission to publish streams.
                    // So there is no need to publish again
                    startLocalAudioCapture(roomId, false);
                } else {
                    XLog.d("Not a teacher or stream already exists for "
                            + user.getUserInfo().getUserUuid() + " stream id:" +
                            user.getUserInfo().getStreamUuid());
                }
            }

            @Override
            public void onFailure(int code, @Nullable String reason) {
                listener.onJoinFail(code, reason);
            }
        });
    }

    private EduUserRole convertRole(Const.Role role) {
        switch (role) {
            case owner:
            case host:
                return EduUserRole.TEACHER;
            case audience:
            default:
                return EduUserRole.STUDENT;
        }
    }

    @Override
    public void leaveRoom(@NonNull String roomId) {
        stopAudioCaptureAndUnPublish(roomId);
        EduRoom room = mEduRoomMap.get(roomId);
        if (room == null) return;
        room.leave();
        mEduRoomMap.remove(roomId);
        mStreamInfoMap.remove(roomId);
        mPeerMessageListener.removePeerMessageListener(roomId);

        EduCoreRoomEventListener roomListener = mRoomListeners.remove(roomId);
        if (roomListener != null) roomListener.onLeaveRoom();
    }

    @Override
    public void sendRoomChatMessage(@NonNull String roomId, @NonNull String message) {
        EduRoom room = mEduRoomMap.get(roomId);
        if (room != null) {
            EduUser local = room.getLocalUser();
            local.sendRoomChatMessage(message, new EduCallback<EduChatMsg>() {
                @Override
                public void onSuccess(@Nullable EduChatMsg res) {

                }

                @Override
                public void onFailure(int code, @Nullable String reason) {

                }
            });
        }
    }

    private class EduCoreRoomEventListener implements EduRoomEventListener, RoomPeerMessageListener,
            RteStatisticsReportListener, EduUserEventListener {
        private String mRoomId;
        private RoomEventListener mListener;

        EduCoreRoomEventListener(@NonNull String roomId,
                                 @NonNull RoomEventListener listener) {
            mRoomId = roomId;
            mListener = listener;
            addToPeerMessage();
            registerRtcStatListener();
        }

        private void addToPeerMessage() {
            mPeerMessageListener.registerPeerMessageListener(mRoomId, this);
        }

        private void registerRtcStatListener() {
            RteEngineImpl.INSTANCE.setStatisticsReportListener(mRoomId, this);
        }

        @Override
        public void onRemoteUsersInitialized(@NotNull List<? extends EduUserInfo> users, @NotNull EduRoom classRoom) {
            List<RoomUserInfo> list = toUserListFromInfo(classRoom.getFullUserList());
            int teacherCount = classRoom.getTeacherCount();
            EduUserInfo teacherInfo = teacherCount < 1 ? null : classRoom.getTeacherList().get(0);
            RoomUserInfo teacher = teacherInfo == null ? null : toRoomUser(teacherInfo);
            List<RoomStreamInfo> streamList = toStreamList(classRoom.getFullStreamList());
            mListener.onRoomMembersInitialized(teacher, list.size(), list, streamList);

            Map<String, Object> properties = classRoom.getRoomProperties();
            mListener.onRoomPropertyUpdated(getBgIdFromProperty(properties),
                    getSeatInfo(properties), getGiftRank(properties), null);
        }

        @Override
        public void onRemoteUsersJoined(@NotNull List<? extends EduUserInfo> users, @NotNull EduRoom classRoom) {
            List<RoomUserInfo> totalList = toUserListFromInfo(classRoom.getFullUserList());
            List<RoomUserInfo> joinedList = toUserListFromInfo(users);
            mListener.onRoomMembersJoined(totalList.size(), totalList, joinedList.size(), joinedList);
        }

        @Override
        public void onRemoteUsersLeft(@NotNull List<EduUserEvent> userEvents, @NotNull EduRoom classRoom) {
            List<RoomUserInfo> totalList = toUserListFromInfo(classRoom.getFullUserList());
            List<RoomUserInfo> leftList = toUserListFromEvents(userEvents);
            mListener.onRoomMembersLeft(totalList.size(), totalList, leftList.size(), leftList);
        }

        @Override
        public void onRemoteUserUpdated(@NotNull List<EduUserEvent> userEvents, @NotNull EduRoom classRoom) {
            List<RoomUserInfo> updatedList = toUserListFromEvents(userEvents);
            mListener.onRoomMembersUpdated(updatedList.size(), updatedList);
        }

        @Override
        public void onRoomMessageReceived(@NotNull EduMsg message, @NotNull EduRoom classRoom) {

        }

        @Override
        public void onRoomChatMessageReceived(@NotNull EduChatMsg chatMsg, @NotNull EduRoom classRoom) {
            EduUserInfo fromUser = chatMsg.getFromUser();
            mListener.onChatMessageReceive(fromUser.getUserUuid(),
                    fromUser.getUserName(), chatMsg.getMessage());
        }

        @Override
        public void onRemoteStreamsInitialized(@NotNull List<? extends EduStreamInfo> streams, @NotNull EduRoom classRoom) {
            List<? extends EduStreamInfo> fullList = classRoom.getFullStreamList();
            mListener.onStreamInitialized(null, toStreamList(fullList));
        }

        @Override
        public void onRemoteStreamsAdded(@NotNull List<EduStreamEvent> streamEvents, @NotNull EduRoom classRoom) {
            XLog.d("onRemoteStreamsAdded " + streamEvents.size());
            List<RoomStreamInfo> addedList = toStreamListFromEvent(streamEvents);
            EduStreamInfo info = mStreamInfoMap.get(mRoomId);
            RoomStreamInfo streamInfo = info != null ? toStreamInfo(info) : null;
            mListener.onStreamAdded(streamInfo, addedList);
        }

        @Override
        public void onRemoteStreamsUpdated(@NotNull List<EduStreamEvent> streamEvents, @NotNull EduRoom classRoom) {
            String log = "onRemoteStreamsUpdated size " + streamEvents.size() + " ";
            for (EduStreamEvent event : streamEvents) {
                log = log + event.getModifiedStream().getHasAudio() + " ";
            }

            XLog.d(log);

            List<RoomStreamInfo> updatedList = toStreamListFromEvent(streamEvents);
            EduStreamInfo info = mStreamInfoMap.get(mRoomId);
            RoomStreamInfo streamInfo = info != null ? toStreamInfo(info) : null;
            mListener.onStreamUpdated(streamInfo, updatedList);
        }

        @Override
        public void onRemoteStreamsRemoved(@NotNull List<EduStreamEvent> streamEvents, @NotNull EduRoom classRoom) {
            XLog.d("onRemoteStreamsRemoved " + streamEvents.size());
            List<RoomStreamInfo> removeList = toStreamListFromEvent(streamEvents);
            EduStreamInfo info = mStreamInfoMap.get(mRoomId);
            RoomStreamInfo streamInfo = info != null ? toStreamInfo(info) : null;
            mListener.onStreamRemoved(streamInfo, removeList);
        }

        @Override
        public void onRoomStatusChanged(@NotNull RoomStatusEvent event,
                                        @Nullable EduUserInfo operatorUser, @NotNull EduRoom classRoom) {
            if (classRoom.getRoomStatus().getCourseState() == EduRoomState.END) {
                mListener.onRoomEnd();
            }
        }

        @Override
        public void onRoomPropertyChanged(@NotNull EduRoom classRoom, @Nullable Map<String, Object> cause) {
            Map<String, Object> properties = classRoom.getRoomProperties();
            Object prop = properties.get("changeProperties");
            if (prop instanceof Map<?,?>) {
                Map<String, Object> propMap = (Map<String, Object>) prop;
                mListener.onRoomPropertyUpdated(getBgIdFromProperty(propMap),
                        getSeatInfo(propMap), getGiftRank(propMap), getGiftSend(cause));
            }
        }

        @Override
        public void onRemoteUserPropertiesUpdated(@NotNull List<EduUserInfo> userInfos, @NotNull EduRoom classRoom,
                                                  @Nullable Map<String, Object> cause) {

        }

        @Override
        public void onNetworkQualityChanged(@NotNull NetworkQuality quality,
                                            @NotNull EduUserInfo user, @NotNull EduRoom classRoom) {

        }

        @Override
        public void onUserActionMessageReceived(@NotNull EduActionMessage actionMessage) {
            Map<String, ?> map = actionMessage.getPayload();
            if (map == null) return;
            Object obj = map.get("no");
            int no = obj instanceof Double ? ((Double) obj).intValue() : -1;
            obj = map.get("type");
            int type = obj instanceof Double ? ((Double) obj).intValue() : -1;
            mListener.onReceiveSeatBehavior(mRoomId,
                    actionMessage.getFromUser().getUserUuid(),
                    actionMessage.getFromUser().getUserName(), no, type);
        }

        @Override
        public void onRtcStats(@Nullable RtcChannel channel, @Nullable IRtcEngineEventHandler.RtcStats stats) {
            mListener.onRtcStats(channel, stats);
        }

        @Override
        public void onVideoSizeChanged(@Nullable RtcChannel channel, int uid, int width, int height, int rotation) {

        }

        @Override
        public void onLocalUserUpdated(@NotNull EduUserEvent userEvent) {

        }

        @Override
        public void onLocalUserPropertyUpdated(@NotNull EduUserInfo userInfo, @org.jetbrains.annotations.Nullable Map<String, Object> cause) {

        }

        @Override
        public void onLocalStreamAdded(@NotNull EduStreamEvent streamEvent) {
            updateLocalStreamCache(streamEvent.getModifiedStream());
            // My stream is first time added to the room, the stream may
            // be created by me or whoever has the permission.
            // At this time, I must start capture and send audio stream.
            EduStreamInfo info = streamEvent.getModifiedStream();
            android.util.Log.d(TAG, "onLocalStreamAdded " +
                    info.getPublisher().getUserName()
                    + " enableAudio:" + info.getHasAudio());
            handleCapture(info, info.getHasAudio());
            RoomStreamInfo streamInfo = toStreamInfo(streamEvent);

            mListener.onStreamAdded(streamInfo, null);
        }

        @Override
        public void onLocalStreamUpdated(@NotNull EduStreamEvent streamEvent) {
            updateLocalStreamCache(streamEvent.getModifiedStream());
            RoomStreamInfo streamInfo = toStreamInfo(streamEvent);
            android.util.Log.d(TAG, "onLocalStreamUpdated " +
                    streamInfo.userName + " enableAudio:" + streamInfo.enableAudio);
            mListener.onStreamUpdated(streamInfo, null);
        }

        private void updateLocalStreamCache(EduStreamInfo stream) {
            if (!mStreamInfoMap.containsKey(mRoomId)) {
                mStreamInfoMap.put(mRoomId, stream);
            } else {
                EduStreamInfo saved = mStreamInfoMap.get(mRoomId);
                saved.setHasAudio(stream.getHasAudio());
                saved.setHasVideo(stream.getHasVideo());
            }
        }

        @Override
        public void onLocalStreamRemoved(@NotNull EduStreamEvent streamEvent) {
            mStreamInfoMap.remove(mRoomId);

            handleCapture(streamEvent.getModifiedStream(), false);
            RoomStreamInfo streamInfo = toStreamInfo(streamEvent);
            android.util.Log.d(TAG, "onLocalStreamRemoved " + streamInfo.userName
                    + " enableAudio:" + streamInfo.enableAudio);
            streamInfo.enableAudio = false;
            mListener.onStreamRemoved(streamInfo, null);
        }

        private void handleCapture(EduStreamInfo info, boolean hasAudio) {
            EduRoom room = mEduRoomMap.get(mRoomId);
            if (room == null) return;
            handleAudioCapture(mRoomId, room.getLocalUser(), hasAudio, null);
        }

        public void onLeaveRoom() {
            mListener.onRoomLeaved();
        }
    }

    private RoomUserInfo toRoomUser(@NonNull EduUserEvent event) {
        RoomUserInfo result = new RoomUserInfo();
        EduUserInfo user = event.getModifiedUser();
        result.userId = user.getUserUuid();
        result.userName = user.getUserName();
        result.uid = UserUtil.toIntegerUserId(user.getStreamUuid());
        return result;
    }

    private List<RoomUserInfo> toUserListFromEvents(@NonNull List<EduUserEvent> infoList) {
        List<RoomUserInfo> result = new ArrayList<>();
        for (EduUserEvent event : infoList) {
            RoomUserInfo user = toRoomUser(event);
            result.add(user);
        }

        return result;
    }

    private RoomUserInfo toRoomUser(@NonNull EduUserInfo info) {
        RoomUserInfo result = new RoomUserInfo();
        result.userId = info.getUserUuid();
        result.userName = info.getUserName();
        result.role = info.getRole() ==
                EduUserRole.TEACHER ? Const.Role.owner : Const.Role.audience;
        return result;
    }

    private List<RoomUserInfo> toUserListFromInfo(@NonNull List<? extends EduUserInfo> infoList) {
        List<RoomUserInfo> result = new ArrayList<>();
        for (EduUserInfo info : infoList) {
            RoomUserInfo user = toRoomUser(info);
            result.add(user);
        }

        return result;
    }

    private RoomStreamInfo toStreamInfo(@NonNull EduStreamInfo streamInfo) {
        RoomStreamInfo info = new RoomStreamInfo();
        info.userId = streamInfo.getPublisher().getUserUuid();
        info.userName = streamInfo.getPublisher().getUserName();
        info.isOwner = streamInfo.getPublisher().getRole() == EduUserRole.TEACHER;
        info.streamId = streamInfo.getStreamUuid();
        info.streamName = streamInfo.getStreamName();
        info.enableAudio = streamInfo.getHasAudio();
        info.enableVideo = streamInfo.getHasVideo();
        return info;
    }

    private RoomStreamInfo toStreamInfo(@NonNull EduStreamEvent event) {
        return toStreamInfo(event.getModifiedStream());
    }

    private EduStreamInfo toEduStreamInfo(RoomStreamInfo info) {
        EduBaseUserInfo user = new EduBaseUserInfo(
                info.userId, info.userName,
                info.isOwner ? EduUserRole.TEACHER : EduUserRole.STUDENT);
        return new EduStreamInfo(info.streamId, info.streamName,
                VideoSourceType.CAMERA, info.enableVideo, info.enableAudio, user);
    }

    private List<RoomStreamInfo> toStreamList(@NonNull List<? extends EduStreamInfo> streamList) {
        List<RoomStreamInfo> result = new ArrayList<>();
        for (EduStreamInfo info : streamList) {
            RoomStreamInfo stream = toStreamInfo(info);
            result.add(stream);
        }

        return result;
    }

    private List<RoomStreamInfo> toStreamListFromEvent(@NonNull List<EduStreamEvent> eventList) {
        List<RoomStreamInfo> result = new ArrayList<>();
        for (EduStreamEvent info : eventList) {
            RoomStreamInfo stream = toStreamInfo(info);
            result.add(stream);
        }

        return result;
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
                SeatStateData seatStateData = new SeatStateData(no, userId, userName, state);
                result.add(seatStateData);
            }
        }
        return result;
    }

    private List<GiftSendInfo> getGiftRank(@Nullable Map<String, Object> map) {
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

    private GiftSendInfo getGiftSend(@Nullable Map<String, Object> map) {
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
    public void enableLocalAudio(String roomId, boolean publish) {
        startLocalAudioCapture(roomId, publish);
    }

    private void startLocalAudioCapture(String roomId, boolean publish) {
        EduRoom room = mEduRoomMap.get(roomId);
        if (room == null) return;

        handleAudioCapture(roomId, room.getLocalUser(), true, () -> {
            EduUser user = room.getLocalUser();
            // Here we consider that a user can has one stream
            // per room(channel), should be updated if not designed
            // in this way.
            // The local stream data must be stored in map and this
            // is done in callback of "initOrUpdateLocalStream"
            // method.
            if (!mStreamInfoMap.containsKey(roomId)) {
                XLog.w("Stream of user " + user.getUserInfo().getUserName() +
                        " cannot be found");
                return;
            }

            if (publish) {
                EduStreamInfo info = mStreamInfoMap.get(roomId);
                info.setHasAudio(true);
                XLog.d("startLocalAudioCapture " + publish);
                publishStream(user, info, null, null);
            }
        });
    }

    @Override
    public void disableLocalAudio(String roomId) {
        stopAudioCaptureAndUnPublish(roomId);
    }

    private void stopAudioCaptureAndUnPublish(String roomId) {
        EduRoom room = mEduRoomMap.get(roomId);
        if (room == null) return;
        EduUser user = room.getLocalUser();
        handleAudioCapture(roomId, user, false, () -> {
            if (mStreamInfoMap.containsKey(roomId)) {
                EduStreamInfo info = mStreamInfoMap.get(roomId);
                info.setHasAudio(false);
                unPublishStream(user, info);
            }
        });
    }

    // Start or stop the local stream, and acquires the local stream
    // instance, so it must be called before any local stream operations.
    private void handleAudioCapture(String roomId, EduUser user,
                                    boolean enableAudio, Runnable whenSuccess) {
        LocalStreamInitOptions options = new LocalStreamInitOptions(
                user.getUserInfo().getStreamUuid(), false, enableAudio);

        // Here is a fix for an edu sdk issue
        // When my stream is operated by other users (like a teacher controls
        // the stream of a student), I can only receive such events through
        // stream changes. At this time, EduSdk lacks the setting of the
        // my client states (because the operator cannot do it for me).
        if (enableAudio) {
            RteEngineImpl.INSTANCE.setClientRole(roomId, Constants.CLIENT_ROLE_BROADCASTER);
            RteEngineImpl.INSTANCE.publish(roomId);
            RteEngineImpl.INSTANCE.muteLocalStream(false, true);
        }

        user.initOrUpdateLocalStream(options, new EduCallback<EduStreamInfo>() {
            @Override
            public void onSuccess(@Nullable EduStreamInfo res) {
                mStreamInfoMap.remove(roomId);
                if (res != null) mStreamInfoMap.put(roomId, res);
                if (whenSuccess != null) whenSuccess.run();
            }

            @Override
            public void onFailure(int code, @Nullable String reason) {

            }
        });
    }

    private EduUserInfo findRoomUserByUserId(EduRoom room, @NonNull String userId) {
        for (EduUserInfo eduUser : room.getFullUserList()) {
            if (userId.endsWith(eduUser.getUserUuid())) {
                return eduUser;
            }
        }

        return null;
    }

    @Override
    public void enableRemoteAudio(String roomId, String userId) {
        publishUserStream(roomId, userId, true);
    }

    private void publishUserStream(String roomId, String targetUserId, boolean enableAudio) {
        // Create and publish the stream for this user
        EduRoom room = mEduRoomMap.get(roomId);
        if (room == null) return;
        EduUserInfo user = findRoomUserByUserId(room, targetUserId);
        if (user == null) {
            XLog.w("publishStream room user not found " + targetUserId);
        }

        EduStreamInfoImpl info = new EduStreamInfoImpl(
                user.getStreamUuid(), null,
                VideoSourceType.CAMERA, false,
                enableAudio, user, 0L);

        XLog.d("publishUserStream " + enableAudio);
        publishStream(room.getLocalUser(), info, null, null);
    }

    private void publishStream(EduUser user, EduStreamInfo info,
                               Runnable doWhenSuccess, Runnable doWhenFail) {
        user.publishStream(info, new EduCallback<Boolean>() {
            @Override
            public void onSuccess(@Nullable Boolean res) {
                if (doWhenSuccess != null) doWhenSuccess.run();
            }

            @Override
            public void onFailure(int code, @Nullable String reason) {
                if (doWhenFail != null) doWhenFail.run();
            }
        });
    }

    @Override
    public void disableRemoteAudio(String roomId, String userId) {
        unPublishStream(roomId, userId);
    }

    private void unPublishStream(String roomId, String targetUserId) {
        EduRoom room = mEduRoomMap.get(roomId);
        if (room == null) return;
        EduUserInfo user = findRoomUserByUserId(room, targetUserId);
        if (user == null) {
            XLog.w("unpublishStream room user not found " + targetUserId);
        }

        EduStreamInfoImpl info = new EduStreamInfoImpl(
                user.getStreamUuid(), null,
                VideoSourceType.CAMERA, false,
                false, user, 0L);

        XLog.d("unpublishUserStream " + targetUserId);
        unPublishStream(room.getLocalUser(), info);
    }

    private void unPublishStream(EduUser user, EduStreamInfo info) {
        user.unPublishStream(info, new EduCallback<Boolean>() {
            @Override
            public void onSuccess(@Nullable Boolean res) {

            }

            @Override
            public void onFailure(int code, @Nullable String reason) {

            }
        });
    }

    @Override
    public void muteLocalAudio(String roomId, boolean muted) {
        // Mute audio only starts/stops local capture with
        // the stream maintaining in the room
        EduRoom room = mEduRoomMap.get(roomId);
        if (room == null) return;
        EduUser user = room.getLocalUser();
        EduStreamInfo info = mStreamInfoMap.get(roomId);
        if (info == null) {
            XLog.w("Stream of user " + user.getUserInfo().getUserName() +
                    " cannot be found");
            return;
        }

        info.setHasAudio(!muted);
        publishStream(user, info, () -> {
            // Close local audio capture
            handleAudioCapture(roomId, user, !muted, null);
        }, null);
    }

    @Override
    public void muteRemoteAudio(String roomId, RoomStreamInfo info, boolean muted) {
        EduStreamInfo targetStream = toEduStreamInfo(info);
        EduRoom room = mEduRoomMap.get(roomId);
        if (room == null) return;

        EduUser operator = room.getLocalUser();
        targetStream.setHasAudio(!muted);
        // Requests to modify another user's stream, so nothing
        // will be done locally in callbacks.
        publishStream(operator, targetStream, null, null);
    }

    @Override
    public void startAudioMixing(String roomId, String filePath) {
        AudioEffect.startAudioMixing(roomId, filePath);
    }

    @Override
    public void stopAudioMixing() {
        AudioEffect.stopAudioMixing();
    }

    @Override
    public void adjustAudioMixingVolume(int volume) {
        AudioEffect.adjustAudioMixingVolume(volume);
    }

    @Override
    public void enableInEarMonitoring(boolean enable) {
        AudioEffect.enableInEarMonitoring(enable);
    }

    @Override
    public void enableAudioEffect(int type) {
        AudioEffect.enableAudioEffect(type);
    }

    @Override
    public void disableAudioEffect() {
        AudioEffect.disableAudioEffect();
    }

    @Override
    public void set3DHumanVoiceParams(int speed) {
        AudioEffect.set3DHumanVoiceParams(speed);
    }

    @Override
    public void setElectronicParams(int key, int value) {
        AudioEffect.setElectronicParams(key, value);
    }
}
