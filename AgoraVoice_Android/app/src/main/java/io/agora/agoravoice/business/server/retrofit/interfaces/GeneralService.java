package io.agora.agoravoice.business.server.retrofit.interfaces;

import androidx.annotation.NonNull;

import io.agora.agoravoice.business.server.retrofit.model.body.OssBody;
import io.agora.agoravoice.business.server.retrofit.model.responses.GiftListResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.MusicResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.OssResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.StringResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.VersionResp;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.Path;
import retrofit2.http.Query;
import retrofit2.http.Url;

public interface GeneralService {
    @GET("ent/v1/app/version")
    Call<VersionResp> checkVersion(@Query("appCode") String appCode, @Query("osType") int osType,
                                   @Query("terminalType") int terminalType,
                                   @Query("appVersion") String appVersion);

    @GET("{root}/gifts")
    Call<GiftListResp> getGiftList(@Path(value = "root", encoded = true) String rootPath);

    @GET("ent/v1/musics")
    Call<MusicResp> getMusicList();

    @POST("/monitor/apps/{appId}/v1/log/oss/policy")
    Call<OssResp> getOssParams(@Path("appId") @NonNull String appId, @Body OssBody body);

    @POST
    Call<StringResp> logStsCallback(@Url String url);
}
