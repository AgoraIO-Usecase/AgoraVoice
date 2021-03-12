package io.agora.agoravoice.manager;

import androidx.annotation.NonNull;

import io.agora.agoravoice.business.BusinessProxy;
import io.agora.agoravoice.business.server.retrofit.listener.LogServiceListener;

public class GeneralManager {
    private BusinessProxy mProxy;

    public GeneralManager(@NonNull BusinessProxy proxy) {
        mProxy = proxy;
    }

    public void checkVersion(String version) {
        mProxy.checkAppVersion(version);
    }

    public void getMusicList() {
        mProxy.requestMusicList();;
    }

    public void uploadLogs(LogServiceListener listener) {
        mProxy.uploadLogs(listener);
    }
}
