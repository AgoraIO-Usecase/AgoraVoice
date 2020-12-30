package io.agora.agoravoice.business.server.retrofit.model.responses;

public class OssResp extends Resp {
    public OssParamsResponse data;

    public static class OssParamsResponse {
        public String bucketName;
        public String callbackUrl;
        public String callbackBody;
        public String callbackContentType;
        public String ossKey;
        public String accessKeyId;
        public String accessKeySecret;
        public String securityToken;
        public String ossEndpoint;
    }
}
