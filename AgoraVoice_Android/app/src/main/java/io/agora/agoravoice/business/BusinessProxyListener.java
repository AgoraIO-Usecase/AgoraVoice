package io.agora.agoravoice.business;

import java.util.List;

import io.agora.agoravoice.business.definition.struct.AppVersionInfo;
import io.agora.agoravoice.business.definition.struct.GiftInfo;
import io.agora.agoravoice.business.definition.struct.MusicInfo;
import io.agora.agoravoice.business.definition.struct.RoomInfo;
import io.agora.agoravoice.business.server.retrofit.model.responses.RoomListResp;

public interface BusinessProxyListener {
    void onCheckVersionSuccess(AppVersionInfo info);

    void onGetMustList(List<MusicInfo> info);

    void onGetGiftList(List<GiftInfo> info);

    void onCreateUser(String userId, String userName);

    void onEditUserSuccess(String userId, String userName);

    void onLoginSuccess(String userId, String userToken, String rtmToken);

    void onRoomCreated(String roomId, String roomName);

    void onGetRoomList(String nextId, int total, List<RoomListResp.RoomListItem> list);

    void onLeaveRoom();

    void onSeatBehaviorSuccess(int type, String userId, String userName, int no);

    void onSeatBehaviorFail(int type, String userId, String userName, int no, int code, String msg);

    void onSeatStateChanged(int no, int state);

    void onSeatStateChangeFail(int no, int state, int code, String msg);

    void onBusinessFail(int type, int code, String message);
}
