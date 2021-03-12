package io.agora.agoravoice.business.server.retrofit.listener;

public interface LogServiceListener {
    void onOssUploadSuccess(String data);

    void onOssUploadFail(int requestType, String message);
}
