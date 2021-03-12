package io.agora.agoravoice.business.server.retrofit.model.responses;

public class JoinResp extends Resp {
    public JoinRespBody data;

    public static class JoinRespBody {
        public String streamId;
        public String role;
    }
}
