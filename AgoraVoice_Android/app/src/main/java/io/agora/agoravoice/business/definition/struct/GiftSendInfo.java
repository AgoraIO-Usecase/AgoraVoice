package io.agora.agoravoice.business.definition.struct;

public class GiftSendInfo {
    public String userId;
    public String userName;
    public String giftId;
    public int rank;

    public GiftSendInfo(String userId, String userName,
                        String giftId, int rank) {
        this.userId = userId;
        this.userName = userName;
        this.giftId = giftId;
        this.rank = rank;
    }
}
