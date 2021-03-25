package io.agora.agoravoice.business.definition.interfaces;

import androidx.annotation.NonNull;

import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;
import io.agora.agoravoice.utils.Const;

public interface CoreService {
    void login(String uid, VoiceCallback<Void> callback);

    void logout(VoiceCallback<Void> callback);

    void enterRoom(String roomId, String roomName, String userId, String userName,
                   String streamId, Const.Role role, RoomEventListener listener);

    void leaveRoom(@NonNull String roomId);

    void sendRoomChatMessage(@NonNull String roomId, @NonNull String message);

    void startAudioMixing(String roomId, String filePath);

    void stopAudioMixing();

    void adjustAudioMixingVolume(int volume);

    void enableInEarMonitoring(boolean enable);

    void enableAudioEffect(int type);

    void disableAudioEffect();

    void set3DHumanVoiceParams(int speed);

    void setElectronicParams(int key, int value);

    void enableLocalAudio();

    void disableLocalAudio();

    void enableRemoteAudio(String userId);

    void disableRemoteAudio(String userId);

    void muteLocalAudio(boolean muted);

    void muteRemoteAudio(String userId, boolean muted);

    String getCoreServiceVersion();
}
