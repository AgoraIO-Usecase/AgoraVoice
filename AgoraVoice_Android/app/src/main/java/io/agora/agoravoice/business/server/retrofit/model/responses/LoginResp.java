package io.agora.agoravoice.business.server.retrofit.model.responses;

public class LoginResp extends Resp {
    public LoginTokenResp data;

    public static class LoginTokenResp {
        public String userToken;
        public String rtmToken;
    }
}
