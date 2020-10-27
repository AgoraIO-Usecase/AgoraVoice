package io.agora.agoravoice.business.server.retrofit.model.body;

public class ChatMsgBody {
    private String message;
    private int type = 1;

    public ChatMsgBody(String message) {
        this.message = message;
    }
}
