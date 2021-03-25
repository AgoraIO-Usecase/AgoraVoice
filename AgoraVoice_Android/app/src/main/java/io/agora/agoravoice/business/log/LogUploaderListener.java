package io.agora.agoravoice.business.log;

import io.agora.agoravoice.business.server.retrofit.model.responses.OssResp;

public interface LogUploaderListener {
    void onOssParamsResponse(OssResp response);

    void onOssUploadSuccess(String data);

    void onOssParamsFail(int requestType, int code, String message);

    void onOssUploadFail(String errMessage);
}
