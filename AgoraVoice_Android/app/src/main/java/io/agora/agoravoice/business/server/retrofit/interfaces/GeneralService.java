package io.agora.agoravoice.business.server.retrofit.interfaces;

import io.agora.agoravoice.business.server.retrofit.model.responses.GiftListResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.MusicResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.VersionResp;
import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface GeneralService {
    @GET("ent/v1/app/version")
    Call<VersionResp> checkVersion(@Query("appCode") String appCode, @Query("osType") int osType,
                                   @Query("terminalType") int terminalType,
                                   @Query("appVersion") String appVersion);

    @GET("{root}/gifts")
    Call<GiftListResp> getGiftList(@Path(value = "root", encoded = true) String rootPath);

    @GET("ent/v1/musics")
    Call<MusicResp> getMusicList();
}
