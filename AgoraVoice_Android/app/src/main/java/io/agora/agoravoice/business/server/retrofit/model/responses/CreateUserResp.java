package io.agora.agoravoice.business.server.retrofit.model.responses;

public class CreateUserResp extends Resp {
    public UserIdResp data;

    public static class UserIdResp {
        public String userId;
    }
}
