package io.agora.agoravoice.business.definition.interfaces;

public interface VoidCallback {
    void onSuccess();
    void onFailure(int code, String reason);
}
