package io.agora.agoravoice.business.server.retrofit.listener;

import java.util.List;

import io.agora.agoravoice.business.definition.struct.AppVersionInfo;
import io.agora.agoravoice.business.definition.struct.GiftInfo;
import io.agora.agoravoice.business.definition.struct.MusicInfo;

public interface GeneralServiceListener {
    void onAppVersionCheckSuccess(AppVersionInfo info);

    void onGetMusicList(List<MusicInfo> musicList);

    void onGetGiftList(List<GiftInfo> giftList);

    void onGeneralServiceFail(int type, int code, String message);
}
