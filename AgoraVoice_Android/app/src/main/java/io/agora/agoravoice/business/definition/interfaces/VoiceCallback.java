package io.agora.agoravoice.business.definition.interfaces;

public interface VoiceCallback<T> {
    void onSuccess(T param);
    void onFailure(int code, String reason);
}
