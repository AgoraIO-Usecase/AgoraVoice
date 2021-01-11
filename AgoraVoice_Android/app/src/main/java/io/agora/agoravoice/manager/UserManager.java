package io.agora.agoravoice.manager;

import androidx.annotation.NonNull;

import io.agora.agoravoice.business.BusinessProxy;

public class UserManager {
    private BusinessProxy mProxy;

    public UserManager(@NonNull BusinessProxy proxy) {
        mProxy = proxy;
    }

    public void createUser(String userName) {
        mProxy.createUser(userName);
    }

    public void editUser(String token, String userId, String userName) {
        mProxy.editUser(token, userId, userName);
    }

    public void login(String userId) {
        mProxy.login(userId);
    }
}
