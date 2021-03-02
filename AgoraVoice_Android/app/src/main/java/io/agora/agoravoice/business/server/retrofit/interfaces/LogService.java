package io.agora.agoravoice.business.server.retrofit.interfaces;

import androidx.annotation.NonNull;

import io.agora.agoravoice.business.server.retrofit.model.body.OssBody;
import io.agora.agoravoice.business.server.retrofit.model.responses.OssResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.StringResp;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;
import retrofit2.http.Path;
import retrofit2.http.Url;

public interface LogService {
    @POST("/monitor/apps/{appId}/v1/log/oss/policy")
    Call<OssResp> getOssParams(@Path("appId") @NonNull String appId, @Body OssBody body);

    @POST
    Call<StringResp> logStsCallback(@Url String url);
}