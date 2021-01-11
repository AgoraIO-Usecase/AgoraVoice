package io.agora.agoravoice.business.log;

import android.content.Context;

import androidx.annotation.NonNull;

import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSS;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.ServiceException;
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback;
import com.alibaba.sdk.android.oss.common.auth.OSSCredentialProvider;
import com.alibaba.sdk.android.oss.common.auth.OSSStsTokenCredentialProvider;
import com.alibaba.sdk.android.oss.model.PutObjectRequest;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.File;
import java.util.HashMap;

import io.agora.agoravoice.business.server.ServerClient;
import io.agora.agoravoice.business.server.retrofit.listener.LogServiceListener;
import io.agora.agoravoice.business.server.retrofit.model.body.OssBody;
import io.agora.agoravoice.business.server.retrofit.model.requests.Request;
import io.agora.agoravoice.business.server.retrofit.model.responses.OssResp;

public class LogUploader {
    private static final String callbackPath = "/monitor/apps/{appId}/v1/log/oss/callback";

    public static void upload(ServerClient client, @NonNull Context context, @NonNull String appId,
                              @NonNull String host, @NonNull String sourcePath,
                              @NonNull OssBody body, final LogServiceListener listener) {
        client.getOssParams(appId, body, new LogUploaderListener() {
            @Override
            public void onOssParamsResponse(OssResp response) {
                response.data.callbackUrl = client.logStsCallback(host).request()
                        .url().toString().concat(callbackPath);
                Logging.d("oss params obtained " + response.data.ossKey);
                Logging.d("callback url " + response.data.callbackUrl);
                uploadByOss(context, sourcePath, response, listener);
            }

            @Override
            public void onOssUploadSuccess(String data) {
                listener.onOssUploadSuccess(data);
            }

            @Override
            public void onOssParamsFail(int requestType, int code, String message) {
                listener.onOssUploadFail(Request.UPLOAD_LOGS_OSS, message);
            }

            @Override
            public void onOssUploadFail(String message) {
                listener.onOssUploadFail(Request.UPLOAD_LOGS, message);
            }
        });
    }

    private static void uploadByOss(@NonNull Context context, @NonNull String uploadPath,
                                    @NonNull OssResp response, LogServiceListener listener) {
        try {
            File file = new File(new File(uploadPath).getParentFile(), "temp.zip");
            ZipUtils.zipFile(new File(uploadPath), file);

            PutObjectRequest put = new PutObjectRequest(response.data.bucketName,
                    response.data.ossKey, file.getAbsolutePath());
            put.setCallbackParam(new HashMap<String, String>() {{
                put("callbackUrl", response.data.callbackUrl);
                put("callbackBodyType", response.data.callbackContentType);
                put("callbackBody", response.data.callbackBody);
            }});

            OSSCredentialProvider credentialProvider =
                    new OSSStsTokenCredentialProvider(response.data.accessKeyId,
                            response.data.accessKeySecret, response.data.securityToken);

            OSS oss = new OSSClient(context, response.data.ossEndpoint, credentialProvider);
            oss.asyncPutObject(put, new OSSCompletedCallback<PutObjectRequest, PutObjectResult>() {
                @Override
                public void onSuccess(PutObjectRequest request, PutObjectResult result) {
                    file.delete();
                    String body = result.getServerCallbackReturnBody();
                    Logging.d("oss async object success " + body);
                    JsonObject json = new JsonParser().parse(body).getAsJsonObject();
                    listener.onOssUploadSuccess(json.get("data").getAsString());
                }

                @Override
                public void onFailure(PutObjectRequest request, ClientException clientException,
                                      ServiceException serviceException) {
                    file.delete();
                    Logging.d("oss async object fail " + clientException.getMessage());
                    listener.onOssUploadFail(Request.UPLOAD_LOGS, clientException.getMessage());
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
