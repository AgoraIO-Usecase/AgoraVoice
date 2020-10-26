package io.agora.agoravoice.business.definition.interfaces;

import androidx.annotation.NonNull;

import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;
import io.agora.agoravoice.utils.Const;

public interface CoreService {
    void login(String uid, VoidCallback callback);

    void enterRoom(String roomId, String roomName, String userId,
                   String userName, Const.Role role, RoomEventListener listener);

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

    void enableLocalAudio(String roomId, boolean publish);

    void disableLocalAudio(String roomId);

    void enableRemoteAudio(String roomId, String userId);

    void disableRemoteAudio(String roomId, String userId);

    void muteLocalAudio(String roomId, boolean muted);

    void muteRemoteAudio(String roomId, RoomStreamInfo info, boolean muted);
}
