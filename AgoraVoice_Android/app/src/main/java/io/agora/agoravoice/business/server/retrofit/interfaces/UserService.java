package io.agora.agoravoice.business.server.retrofit.interfaces;

import io.agora.agoravoice.business.server.retrofit.model.body.CreateUserBody;
import io.agora.agoravoice.business.server.retrofit.model.body.EditUserBody;
import io.agora.agoravoice.business.server.retrofit.model.body.LoginBody;
import io.agora.agoravoice.business.server.retrofit.model.responses.BooleanResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.CreateUserResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.JoinResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.LoginResp;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.Path;

public interface UserService {
    @POST("{root}/apps/{appId}/v1/users/login")
    Call<LoginResp> login(@Path(value = "root", encoded = true) String rootPath,
                          @Path("appId") String appId, @Body LoginBody body);

    @POST("{root}/apps/{appId}/v1/rooms/{roomId}/users/{userId}/join")
    Call<JoinResp> join(@Header("token") String token,
                        @Path(value = "root", encoded = true) String rootPath,
                        @Path("appId") String appId, @Path("roomId") String roomId,
                        @Path("userId") String userId);

    @POST("{root}/apps/{appId}/v1/users")
    Call<CreateUserResp> createUser(@Path(value = "root", encoded = true) String rootPath,
                                    @Path("appId") String appId, @Body CreateUserBody body);

    @POST("{root}/apps/{appId}/v1/users/{userId}")
    Call<BooleanResp> editUser(@Path(value = "root", encoded = true) String rootPath,
                               @Path("appId") String appId, @Header("token") String token,
                               @Path("userId") String userId, @Body EditUserBody body);
}
