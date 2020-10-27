package io.agora.agoravoice.business.server.retrofit.model.body;

public class SendGiftBody {
    private String giftId;
    private int count;

    public SendGiftBody(String id, int count) {
        this.giftId = id;
        this.count = count;
    }
}
