package io.agora.agoravoice.business.server.retrofit.listener;

public interface UserServiceListener {
    void onUserCreateSuccess(String userId, String userName);

    void onUserEditSuccess(String userId, String userName);

    void onLoginSuccess(String userId, String userToken, String rtmToken);

    void onUserServiceFailed(int type, int code, String msg);
}
