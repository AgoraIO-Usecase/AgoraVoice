package io.agora.agoravoice.business.server;

import androidx.annotation.NonNull;

import com.elvishew.xlog.XLog;

import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import io.agora.agoravoice.BuildConfig;
import io.agora.agoravoice.business.server.retrofit.interfaces.GeneralService;
import io.agora.agoravoice.business.server.retrofit.interfaces.SeatService;
import io.agora.agoravoice.business.server.retrofit.interfaces.RoomService;
import io.agora.agoravoice.business.server.retrofit.interfaces.UserService;
import io.agora.agoravoice.business.server.retrofit.listener.GeneralServiceListener;
import io.agora.agoravoice.business.server.retrofit.listener.RoomServiceListener;
import io.agora.agoravoice.business.server.retrofit.listener.SeatServiceListener;
import io.agora.agoravoice.business.server.retrofit.listener.UserServiceListener;
import io.agora.agoravoice.business.server.retrofit.model.body.ChatMsgBody;
import io.agora.agoravoice.business.server.retrofit.model.body.CreateRoomBody;
import io.agora.agoravoice.business.server.retrofit.model.body.CreateUserBody;
import io.agora.agoravoice.business.server.retrofit.model.body.EditUserBody;
import io.agora.agoravoice.business.server.retrofit.model.body.ModifyRoomBody;
import io.agora.agoravoice.business.server.retrofit.model.body.SeatBehaviorBody;
import io.agora.agoravoice.business.server.retrofit.model.body.LoginBody;
import io.agora.agoravoice.business.server.retrofit.model.body.SeatStateBody;
import io.agora.agoravoice.business.server.retrofit.model.body.SendGiftBody;
import io.agora.agoravoice.business.server.retrofit.model.requests.Request;
import io.agora.agoravoice.business.server.retrofit.model.responses.BooleanResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.CreateUserResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.GiftListResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.LoginResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.MusicResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.Resp;
import io.agora.agoravoice.business.server.retrofit.model.responses.RoomListResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.StringResp;
import io.agora.agoravoice.business.server.retrofit.model.responses.VersionResp;
import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.internal.EverythingIsNonNull;

public class ServerClient {
    private static final String SERVER_HOST = "https://api-solutions-dev.sh.agoralab.co";
    private static final String ERROR_UNKNOWN_MSG = "";

    private static final int MAX_RESPONSE_THREAD = 10;
    private static final int DEFAULT_TIMEOUT_IN_SECONDS = 30;

    private static final int ERROR_OK = 0;
    private static final int ERROR_UNKNOWN = -1;
    private static final int ERROR_CONNECTION = -2;

    private GeneralService mGeneralService;
    private UserService mUserService;
    private RoomService mRoomService;
    private SeatService mSeatService;

    public ServerClient() {
        OkHttpClient okHttpClient = new OkHttpClient().newBuilder()
                .connectTimeout(DEFAULT_TIMEOUT_IN_SECONDS, TimeUnit.SECONDS)
                .readTimeout(DEFAULT_TIMEOUT_IN_SECONDS, TimeUnit.SECONDS)
                .writeTimeout(DEFAULT_TIMEOUT_IN_SECONDS, TimeUnit.SECONDS)
                .build();

        Retrofit.Builder builder = new Retrofit.Builder()
                .baseUrl(SERVER_HOST)
                .client(okHttpClient)
                .callbackExecutor(Executors.newFixedThreadPool(MAX_RESPONSE_THREAD))
                .addConverterFactory(GsonConverterFactory.create());

        if (BuildConfig.DEBUG) {
            HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor(XLog::d);
            interceptor.level(HttpLoggingInterceptor.Level.BODY);
            OkHttpClient client = new OkHttpClient.Builder().addInterceptor(interceptor).build();
            builder.client(client);
        }

        Retrofit retrofit = builder.build();
        mGeneralService = retrofit.create(GeneralService.class);
        mUserService = retrofit.create(UserService.class);
        mRoomService = retrofit.create(RoomService.class);
        mSeatService = retrofit.create(SeatService.class);
    }

    public void checkVersion(@NonNull String appCode, int osType, int terminalType,
                             @NonNull String version, @NonNull GeneralServiceListener listener) {
        mGeneralService.checkVersion(appCode, osType, terminalType, version).enqueue(new Callback<VersionResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<VersionResp> call, Response<VersionResp> response) {
                VersionResp resp = response.body();
                if (resp == null || resp.data == null) {
                    listener.onGeneralServiceFail(Request.CHECK_VERSION, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onGeneralServiceFail(Request.CHECK_VERSION, resp.code, resp.msg);
                } else {
                    listener.onAppVersionCheckSuccess(resp.data);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<VersionResp> call, Throwable t) {
                listener.onGeneralServiceFail(Request.CHECK_VERSION, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void musicInfoList(GeneralServiceListener listener) {
        mGeneralService.getMusicList().enqueue(new Callback<MusicResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<MusicResp> call, Response<MusicResp> response) {
                MusicResp resp = response.body();
                if (resp == null || resp.data == null) {
                    listener.onGeneralServiceFail(Request.MUSIC_LIST, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onGeneralServiceFail(Request.MUSIC_LIST, resp.code, resp.msg);
                } else {
                    listener.onGetMusicList(resp.data);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<MusicResp> call, Throwable t) {
                listener.onGeneralServiceFail(Request.MUSIC_LIST, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void giftList(GeneralServiceListener listener) {
        mGeneralService.getGiftList().enqueue(new Callback<GiftListResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<GiftListResp> call, Response<GiftListResp> response) {
                GiftListResp resp = response.body();
                if (resp == null || resp.data == null) {
                    listener.onGeneralServiceFail(Request.GIFT_LIST, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onGeneralServiceFail(Request.GIFT_LIST, resp.code, resp.msg);
                } else {
                    listener.onGetGiftList(resp.data);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<GiftListResp> call, Throwable t) {
                listener.onGeneralServiceFail(Request.GIFT_LIST, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void createUser(@NonNull String userName, @NonNull UserServiceListener listener) {
        mUserService.createUser(new CreateUserBody(userName)).enqueue(new Callback<CreateUserResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<CreateUserResp> call, Response<CreateUserResp> response) {
                CreateUserResp resp = response.body();
                if (resp == null || resp.data == null) {
                    listener.onUserServiceFailed(Request.CREATE_USER, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onUserServiceFailed(Request.CREATE_USER, resp.code, resp.msg);
                } else {
                    listener.onUserCreateSuccess(resp.data.userId, userName);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<CreateUserResp> call, Throwable t) {
                listener.onUserServiceFailed(Request.CREATE_USER, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void editUserSuccess(@NonNull String token, @NonNull final String userId,
                                @NonNull final String userName, @NonNull UserServiceListener listener) {
        mUserService.editUser(token, userId, new EditUserBody(userName)).enqueue(new Callback<BooleanResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<BooleanResp> call, Response<BooleanResp> response) {
                BooleanResp resp = response.body();
                if (resp == null) {
                    listener.onUserServiceFailed(Request.EDIT_USER, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onUserServiceFailed(Request.EDIT_USER, resp.code, resp.msg);
                } else {
                    listener.onUserEditSuccess(userId, userName);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<BooleanResp> call, Throwable t) {
                listener.onUserServiceFailed(Request.EDIT_USER, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void login(@NonNull String userId, @NonNull UserServiceListener listener) {
        mUserService.login(new LoginBody(userId)).enqueue(new Callback<LoginResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<LoginResp> call, Response<LoginResp> response) {
                LoginResp resp = response.body();
                if (resp == null || resp.data == null) {
                    listener.onUserServiceFailed(Request.LOGIN, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onUserServiceFailed(Request.LOGIN, resp.code, resp.msg);
                } else {
                    listener.onLoginSuccess(userId, resp.data.userToken, resp.data.rtmToken);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<LoginResp> call, Throwable t) {
                listener.onUserServiceFailed(Request.LOGIN, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void createRoom(@NonNull String token, @NonNull String roomName,
                           @NonNull String image, @NonNull RoomServiceListener listener) {
        mRoomService.createRoom(token, new CreateRoomBody(roomName, image)).enqueue(new Callback<StringResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<StringResp> call, Response<StringResp> response) {
                StringResp resp = response.body();
                if (resp == null || resp.data == null) {
                    listener.onRoomServiceFailed(Request.CREATE_ROOM, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onRoomServiceFailed(Request.CREATE_ROOM, resp.code, resp.msg);
                } else {
                    listener.onRoomCreated(resp.data, roomName);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<StringResp> call, Throwable t) {
                listener.onRoomServiceFailed(Request.CREATE_ROOM, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void destroyRoom(@NonNull String token, @NonNull String roomId, @NonNull RoomServiceListener listener) {
        mRoomService.destroyRoom(token, roomId).enqueue(new Callback<BooleanResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<BooleanResp> call, Response<BooleanResp> response) {
                BooleanResp resp = response.body();
                if (resp == null) {
                    listener.onRoomServiceFailed(Request.LEAVE_ROOM, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onRoomServiceFailed(Request.LEAVE_ROOM, resp.code, resp.msg);
                } else {
                    listener.onLeaveRoom(roomId);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<BooleanResp> call, Throwable t) {
                listener.onRoomServiceFailed(Request.LEAVE_ROOM, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void getRoomList(@NonNull String token, final String nextId,
                            int count, int type, @NonNull RoomServiceListener listener) {
        mRoomService.getRoomList(token, nextId, count, type).enqueue(new Callback<RoomListResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<RoomListResp> call, Response<RoomListResp> response) {
                RoomListResp resp = response.body();
                if (resp == null || resp.data == null) {
                    listener.onRoomServiceFailed(Request.ROOM_LIST, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onRoomServiceFailed(Request.ROOM_LIST, resp.code, resp.msg);
                } else {
                    listener.onGetRoomList(nextId, resp.data.total, resp.data.list);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<RoomListResp> call, Throwable t) {
                listener.onRoomServiceFailed(Request.ROOM_LIST, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void sendGift(@NonNull String token, @NonNull String roomId,
                         @NonNull String giftId, int count, @NonNull RoomServiceListener listener) {
        mRoomService.sendGift(token, roomId, new SendGiftBody(giftId, count))
            .enqueue(new Callback<BooleanResp>() {
                @Override
                @EverythingIsNonNull
                public void onResponse(Call<BooleanResp> call, Response<BooleanResp> response) {
                    BooleanResp resp = response.body();
                    if (resp == null) {
                        listener.onRoomServiceFailed(Request.SEND_GIFT, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                    } else if (!resp.data) {
                        listener.onRoomServiceFailed(Request.SEND_GIFT, resp.code, resp.msg);
                    }
                }

                @Override
                @EverythingIsNonNull
                public void onFailure(Call<BooleanResp> call, Throwable t) {
                    listener.onRoomServiceFailed(Request.SEND_GIFT, ERROR_CONNECTION, t.getMessage());
                }
            });
    }

    public void modifyRoom(@NonNull String token, @NonNull String roomId,
                           String backgroundId, @NonNull RoomServiceListener listener) {
        mRoomService.modifyRoom(token, roomId, new ModifyRoomBody(backgroundId))
                .enqueue(new Callback<BooleanResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<BooleanResp> call, Response<BooleanResp> response) {
                BooleanResp resp = response.body();
                if (resp == null) {
                    listener.onRoomServiceFailed(Request.MODIFY_ROOM, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (!resp.data) {
                    listener.onRoomServiceFailed(Request.MODIFY_ROOM, resp.code, resp.msg);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<BooleanResp> call, Throwable t) {
                listener.onRoomServiceFailed(Request.MODIFY_ROOM, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void sendChatMessage(@NonNull String token, @NonNull String appId,
                                @NonNull String roomId, @NonNull String message,
                                @NonNull RoomServiceListener listener) {
        mRoomService.sendChatMessage(token, appId, roomId, new ChatMsgBody(message))
            .enqueue(new Callback<Resp>() {
                @Override
                @EverythingIsNonNull
                public void onResponse(Call<Resp> call, Response<Resp> response) {
                    Resp resp = response.body();
                    if (resp == null) {
                        listener.onRoomServiceFailed(Request.SEND_CHAT, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                    } else if (resp.code != ERROR_OK) {
                        listener.onRoomServiceFailed(Request.SEND_CHAT, resp.code, resp.msg);
                    }
                }

                @Override
                @EverythingIsNonNull
                public void onFailure(Call<Resp> call, Throwable t) {
                    listener.onRoomServiceFailed(Request.SEND_CHAT, ERROR_CONNECTION, t.getMessage());
                }
            }
        );
    }

    public void requestSeatBehavior(@NonNull String token, @NonNull String roomId,
                                    @NonNull String userId, String userName,
                                    int no, int type, SeatServiceListener listener) {
        mSeatService.requestSeatBehavior(token, roomId, userId,
                new SeatBehaviorBody(no, type)).enqueue(new Callback<StringResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<StringResp> call, Response<StringResp> response) {
                StringResp resp = response.body();
                if (resp == null) {
                    listener.onSeatBehaviorFail(type, userId, userName, no, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (resp.code != ERROR_OK) {
                    listener.onSeatBehaviorFail(type, userId, userName, no, resp.code, resp.msg);
                } else {
                    listener.onSeatBehaviorSuccess(roomId, type, userId, userName, no, resp.code, resp.msg);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<StringResp> call, Throwable t) {
                listener.onSeatBehaviorFail(type, userId, userName, no, ERROR_CONNECTION, t.getMessage());
            }
        });
    }

    public void requestSeatStateChange(@NonNull String token, @NonNull String roomId,
                                       int no, int state, SeatServiceListener listener) {
        mSeatService.modifySeatState(token, roomId, new SeatStateBody(no, state)).enqueue(new Callback<BooleanResp>() {
            @Override
            @EverythingIsNonNull
            public void onResponse(Call<BooleanResp> call, Response<BooleanResp> response) {
                BooleanResp resp = response.body();
                if (resp == null) {
                    listener.onSeatStateChangeFail(no, state, ERROR_UNKNOWN, ERROR_UNKNOWN_MSG);
                } else if (!resp.data) {
                    listener.onSeatStateChangeFail(no, state, resp.code, resp.msg);
                } else {
                    listener.onSeatStateChanged(no, state);
                }
            }

            @Override
            @EverythingIsNonNull
            public void onFailure(Call<BooleanResp> call, Throwable t) {
                listener.onSeatStateChangeFail(no, state, ERROR_CONNECTION, t.getMessage());
            }
        });
    }
}