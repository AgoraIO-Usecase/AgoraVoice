package io.agora.agoravoice.business.server.retrofit.interfaces;

import io.agora.agoravoice.business.server.retrofit.model.body.SeatBehaviorBody;
import io.agora.agoravoice.business.server.retrofit.model.body.SeatStateBody;
import io.agora.agoravoice.business.server.retrofit.model.responses.BooleanResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.StringResp;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.Path;

public interface SeatService {
    @POST("{root}/apps/{appId}/v1/rooms/{roomId}/users/{userId}/seats")
    Call<StringResp> requestSeatBehavior(@Path(value = "root", encoded = true) String rootPath,
                                         @Path("appId") String appId, @Header("token") String token,
                                         @Path("roomId") String roomId, @Path("userId") String userId,
                                         @Body SeatBehaviorBody body);

    @POST("{root}/apps/{appId}/v1/rooms/{roomId}/seats")
    Call<BooleanResp> modifySeatState(@Path(value = "root", encoded = true) String rootPath,
                                      @Path("appId") String appId, @Header("token") String token,
                                      @Path("roomId") String roomId, @Body SeatStateBody body);
}
