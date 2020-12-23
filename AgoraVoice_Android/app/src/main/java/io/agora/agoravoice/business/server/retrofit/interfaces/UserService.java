package io.agora.agoravoice.business.server.retrofit.interfaces;

import io.agora.agoravoice.business.server.retrofit.model.body.CreateUserBody;
import io.agora.agoravoice.business.server.retrofit.model.body.EditUserBody;
import io.agora.agoravoice.business.server.retrofit.model.body.LoginBody;
import io.agora.agoravoice.business.server.retrofit.model.responses.BooleanResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.CreateUserResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.LoginResp;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.Path;

public interface UserService {
    @POST("ent/voice/v1/users/login")
    Call<LoginResp> login(@Body LoginBody body);

    @POST("ent/voice/v1/users")
    Call<CreateUserResp> createUser(@Body CreateUserBody body);

    @POST("ent/voice/v1/users/{userId}")
    Call<BooleanResp> editUser(@Header("token") String token, @Path("userId") String userId, @Body EditUserBody body);
}
