package io.agora.agoravoice.business.implement.rte;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.agora.agoravoice.business.definition.interfaces.*;
import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;
import io.agora.agoravoice.utils.Const;

public class RteCoreService implements CoreService {
    public RteCoreService(@NonNull Context context, @NonNull String appId,
                          @Nullable String certificate, @NonNull String customerId,
                          @Nullable String logFileDir, int logLevel) {

    }

    @Override
    public void login(String uid, VoidCallback callback) {

    }

    @Override
    public void enterRoom(String roomId, String roomName, String userId,
                          String userName, Const.Role role, RoomEventListener listener) {

    }

    @Override
    public void leaveRoom(@NonNull String roomId) {

    }

    @Override
    public void sendRoomChatMessage(@NonNull String roomId, @NonNull String message) {

    }

    @Override
    public void startAudioMixing(String roomId, String filePath) {

    }

    @Override
    public void stopAudioMixing() {

    }

    @Override
    public void adjustAudioMixingVolume(int volume) {

    }

    @Override
    public void enableInEarMonitoring(boolean enable) {

    }

    @Override
    public void enableAudioEffect(int type) {

    }

    @Override
    public void disableAudioEffect() {

    }

    @Override
    public void set3DHumanVoiceParams(int speed) {

    }

    @Override
    public void setElectronicParams(int key, int value) {

    }

    @Override
    public void enableLocalAudio(String roomId, boolean publish) {

    }

    @Override
    public void disableLocalAudio(String roomId) {

    }

    @Override
    public void enableRemoteAudio(String roomId, String userId) {

    }

    @Override
    public void disableRemoteAudio(String roomId, String userId) {

    }

    @Override
    public void muteLocalAudio(String roomId, boolean muted) {

    }

    @Override
    public void muteRemoteAudio(String roomId, RoomStreamInfo info, boolean muted) {

    }
}
