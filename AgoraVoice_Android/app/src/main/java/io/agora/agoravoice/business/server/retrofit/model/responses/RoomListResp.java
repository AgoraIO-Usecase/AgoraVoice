package io.agora.agoravoice.business.server.retrofit.model.responses;

import java.util.List;

import io.agora.agoravoice.business.definition.struct.RoomInfo;

public class RoomListResp extends Resp {
    public RoomList data;

    public static class RoomList {
        public int count;
        public int total;
        public String nextId;
        public List<RoomListItem> list;
    }

    public static class RoomListItem {
        public String appId;
        public String roomName;
        public String roomId;
        public String channelName;
        public String backgroundImage;
        public int onlineUsers;
        public int state;
        public OwnerUserInfo ownerUserInfo;
    }

    public static class OwnerUserInfo {
        public String userName;
        public String userId;
    }
}
