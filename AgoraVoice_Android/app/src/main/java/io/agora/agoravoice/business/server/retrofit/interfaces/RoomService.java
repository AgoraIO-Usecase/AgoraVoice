package io.agora.agoravoice.business.server.retrofit.interfaces;

import io.agora.agoravoice.business.server.retrofit.model.body.ChatMsgBody;
import io.agora.agoravoice.business.server.retrofit.model.body.CreateRoomBody;
import io.agora.agoravoice.business.server.retrofit.model.body.ModifyRoomBody;
import io.agora.agoravoice.business.server.retrofit.model.body.SendGiftBody;
import io.agora.agoravoice.business.server.retrofit.model.responses.BooleanResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.Resp;
import io.agora.agoravoice.business.server.retrofit.model.responses.RoomListResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.StringResp;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.PATCH;
import retrofit2.http.POST;
import retrofit2.http.PUT;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface RoomService {
    @POST("{root}/apps/{appId}/v1/rooms")
    Call<StringResp> createRoom(@Path(value = "root", encoded = true) String rootPath,
                                @Path("appId") String appId, @Header("token") String token,
                                @Body CreateRoomBody body);

    @POST("{root}/apps/{appId}/v1/rooms/{roomId}/close")
    Call<BooleanResp> closeRoom(@Path(value = "root", encoded = true) String rootPath,
                                @Path("appId") String appId, @Header("token") String token,
                                @Path("roomId") String roomId);

    @POST("{root}/apps/{appId}/v1/rooms/{roomId}/users/{userId}/leave")
    Call<BooleanResp> leaveRoom(@Path(value = "root", encoded = true) String rootPath,
                                @Header("token") String token,
                                @Path("appId") String appId,
                                @Path("roomId") String roomId,
                                @Path("userId") String userId);

    @GET("{root}/apps/{appId}/v1/rooms/page")
    Call<RoomListResp> getRoomList(@Path(value = "root", encoded = true) String rootPath,
                                   @Path("appId") String appId, @Header("token") String token,
                                   @Query("nextId") String nextId, @Query("count") int count,
                                   @Query("type") int type);

    @POST("{root}/apps/{appId}/v1/rooms/{roomId}/gifts")
    Call<BooleanResp> sendGift(@Path(value = "root", encoded = true) String rootPath,
                               @Path("appId") String appId, @Header("token") String token,
                               @Path("roomId") String roomId, @Body SendGiftBody body);

    @PUT("{root}/apps/{appId}/v1/rooms/{roomId}")
    Call<BooleanResp> modifyRoom(@Path(value = "root", encoded = true) String rootPath,
                                 @Path("appId") String appId, @Header("token") String token,
                                 @Path("roomId") String roomId, @Body ModifyRoomBody body);

    @POST("scene/apps/{appId}/v1/rooms/{roomUuid}/chat/channel")
    Call<Resp> sendChatMessage(@Header("token") String token, @Path("appId") String appId,
                               @Path("roomUuid") String roomId, @Body ChatMsgBody body);
}
