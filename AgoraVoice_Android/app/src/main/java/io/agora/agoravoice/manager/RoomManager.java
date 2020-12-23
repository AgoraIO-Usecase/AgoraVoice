package io.agora.agoravoice.manager;

import androidx.annotation.NonNull;

import io.agora.agoravoice.business.BusinessProxy;
import io.agora.agoravoice.business.definition.interfaces.RoomEventListener;
import io.agora.agoravoice.business.server.retrofit.listener.RoomServiceListener;
import io.agora.agoravoice.utils.Const;

public class RoomManager {
    private BusinessProxy mProxy;

    public RoomManager(@NonNull BusinessProxy proxy) {
        mProxy = proxy;
    }

    public void createRoom(String token, String roomName, String image) {
        mProxy.createRoom(token, roomName, image);
    }

    public void getRoomList(String token, String nextId, int count, int type) {
        mProxy.getRoomList(token, nextId, count, type);
    }

    public void enterRoom(String roomId, String roomName, String userId,
                          String userName, Const.Role role, RoomEventListener listener) {
        mProxy.enterRoom(roomId, roomName, userId, userName, role, listener);
    }

    public void leaveRoom(String token, String roomId) {
        mProxy.leaveRoom(roomId);
    }

    public void sendGift(String token, String roomId, String giftId, int count) {
        mProxy.sendGift(token, roomId, giftId, count);
    }

    public void modifyRoom(@NonNull String token, @NonNull String roomId, String backgroundId) {
        mProxy.modifyRoom(token, roomId, backgroundId);
    }

    public void sendChatMessage(@NonNull String token, @NonNull String appId,
                                @NonNull String roomId, @NonNull String message) {
        mProxy.sendChatMessage(token, appId, roomId, message);
    }

    public void destroyRoom(String token, String roomId) {
        mProxy.destroyRoom(token, roomId);
    }
}
