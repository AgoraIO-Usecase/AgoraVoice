package io.agora.agoravoice.business.server.retrofit.listener;

import java.util.List;

import io.agora.agoravoice.business.definition.struct.RoomInfo;
import io.agora.agoravoice.business.server.retrofit.model.responses.RoomListResp;

public interface RoomServiceListener {
    void onRoomCreated(String roomId, String roomName);

    void onLeaveRoom(String roomId);

    void onGetRoomList(String nextId, int count, List<RoomListResp.RoomListItem> list);

    void onRoomServiceFailed(int type, int code, String msg);
}
