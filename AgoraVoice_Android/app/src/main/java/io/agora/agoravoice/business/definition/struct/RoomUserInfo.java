package io.agora.agoravoice.business.definition.struct;

import io.agora.agoravoice.utils.Const;

public class RoomUserInfo {
    public String userId;
    public String userName;
    public Const.Role role;
    public int uid;
    public String streamId;

    public RoomUserInfo() {

    }

    public RoomUserInfo(String userId, String userName,
                        Const.Role role, int uid,
                        String streamId) {
        this.userId = userId;
        this.userName = userName;
        this.role = role;
        this.uid = uid;
        this.streamId = streamId;
    }
}
