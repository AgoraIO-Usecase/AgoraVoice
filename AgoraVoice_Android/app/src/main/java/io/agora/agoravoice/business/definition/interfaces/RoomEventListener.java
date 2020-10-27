package io.agora.agoravoice.business.definition.interfaces;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.List;

import io.agora.agoravoice.business.definition.struct.GiftSendInfo;
import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;
import io.agora.agoravoice.business.definition.struct.RoomUserInfo;
import io.agora.agoravoice.business.definition.struct.SeatStateData;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcChannel;

public interface RoomEventListener {
    void onJoinSuccess(String roomId, String roomName);

    void onJoinFail(int code, String reason);

    void onRoomLeaved();

    void onRoomEnd();

    void onRoomMembersInitialized(@Nullable RoomUserInfo owner, int count, List<RoomUserInfo> userList, List<RoomStreamInfo> streamInfo);

    void onRoomMembersJoined(int total, List<RoomUserInfo> totalList, int joinCount, List<RoomUserInfo> joinedList);

    void onRoomMembersLeft(int total, List<RoomUserInfo> totalList, int leftCount, List<RoomUserInfo> leftList);

    void onRoomMembersUpdated(int count, List<RoomUserInfo> updatedList);

    void onChatMessageReceive(String fromUserId, String fromUserName, String message);

    void onStreamInitialized(RoomStreamInfo myStreamInfo, List<RoomStreamInfo> streamList);

    void onStreamAdded(RoomStreamInfo myStreamInfo, List<RoomStreamInfo> addList);

    void onStreamUpdated(RoomStreamInfo myStreamInfo, List<RoomStreamInfo> updatedList);

    void onStreamRemoved(RoomStreamInfo myStreamInfo, List<RoomStreamInfo> removeList);

    void onRoomPropertyUpdated(@NonNull String backgroundId, @Nullable List<SeatStateData> seats,
                               @Nullable List<GiftSendInfo> giftRank, @Nullable GiftSendInfo giftSent);

    void onReceiveSeatBehavior(@NonNull String roomId, String fromUserId, String fromUserName, int no, int behavior);

    void onRtcStats(@Nullable RtcChannel channel, @Nullable IRtcEngineEventHandler.RtcStats stats);
}
