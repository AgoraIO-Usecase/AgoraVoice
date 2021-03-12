package io.agora.agoravoice;

import android.text.TextUtils;

import java.util.ArrayList;
import java.util.List;

import io.agora.agoravoice.business.definition.struct.GiftInfo;
import io.agora.agoravoice.business.definition.struct.MusicInfo;
import io.agora.agoravoice.manager.AudioManager;

public class Config {
    private static final int DEFAULT_3D_VOICE_SPEED = 10;
    private static final int DEFAULT_ELECTRONIC_KEY = 1;
    private static final int DEFAULT_ELECTRONIC_VALUE = 4;

    private volatile String mAppId;
    private volatile String mUserToken;
    private volatile String mRtmToken;
    private volatile String mUserId;
    private volatile String mNickname;

    private volatile int mCurMusicIndex = -1;

    private boolean mAudioMuted;

    private List<MusicInfo> mMusicInfo = new ArrayList<>();
    private List<GiftInfo> mGiftInfo = new ArrayList<>();

    private int mBgMusicVolume = 100;

    private boolean mInEarMonitoring;

    private int mAudioEffectType = -1;

    private int m3DVoiceSpeed = DEFAULT_3D_VOICE_SPEED;

    private int mElectronicKey = DEFAULT_ELECTRONIC_KEY;

    private int mElectronicValue = DEFAULT_ELECTRONIC_VALUE;

    private int mBgImageSelected = -1;

    public void reset3DVoiceEffect() {
        m3DVoiceSpeed = DEFAULT_3D_VOICE_SPEED;
    }

    public void resetElectronicEffect() {
        mElectronicKey = DEFAULT_ELECTRONIC_KEY;
        mElectronicValue = DEFAULT_ELECTRONIC_VALUE;
    }

    public String getAppId() {
        return mAppId;
    }

    public void setAppId(String mAppId) {
        this.mAppId = mAppId;
    }

    public String getUserToken() {
        return mUserToken;
    }

    public void setUserToken(String mUserToken) {
        this.mUserToken = mUserToken;
    }

    public String getRtmToken() {
        return mRtmToken;
    }

    public void setRtmToken(String mRtmToken) {
        this.mRtmToken = mRtmToken;
    }

    public String getUserId() {
        return mUserId;
    }

    public void setUserId(String mUserId) {
        this.mUserId = mUserId;
    }

    public String getNickname() {
        return mNickname;
    }

    public void setNickname(String mNickname) {
        this.mNickname = mNickname;
    }

    public boolean isAppIdValid() {
        return !TextUtils.isEmpty(mAppId);
    }

    public boolean isUserExisted() {
        return !TextUtils.isEmpty(mUserId);
    }

    public boolean userHasLogin() {
        return !TextUtils.isEmpty(mUserToken);
    }

    public void updateMusicInfo(List<MusicInfo> list) {
        mMusicInfo.clear();
        mMusicInfo.addAll(list);
    }

    public List<MusicInfo> getMusicInfo() {
        return mMusicInfo;
    }

    public void updateGiftInfo(List<GiftInfo> list) {
        mGiftInfo.clear();
        mGiftInfo.addAll(list);
    }

    public List<GiftInfo> getGiftInfo() {
        return mGiftInfo;
    }

    public int getCurMusicIndex() {
        return mCurMusicIndex;
    }

    public void setCurMusicIndex(int index) {
        mCurMusicIndex = index;
    }

    public int getBgMusicVolume() {
        return mBgMusicVolume;
    }

    public void setBgMusicVolume(int volume) {
        if (volume < 0) {
            mBgMusicVolume = 0;
        } else {
            mBgMusicVolume = Math.min(volume, 100);
        }
    }

    public void setInEarMonitoring(boolean enabled) {
        mInEarMonitoring = enabled;
    }

    public boolean getInEarMonitoring() {
        return mInEarMonitoring;
    }

    public void setAudioEffect(int type) {
        if (type < AudioManager.EFFECT_MALE_MAGNETIC ||
            type > AudioManager.EFFECT_ELECTRONIC)  {
            return;
        }

        mAudioEffectType = type;
    }

    public void disableAudioEffect() {
        mAudioEffectType = -1;
    }

    public int getCurAudioEffect() {
        return mAudioEffectType;
    }

    public void set3DVoiceSpeed(int speed) {
        m3DVoiceSpeed = speed < 1 ? 1 : Math.min(speed, 60);
    }

    public int get3DVoiceSpeed() {
        return m3DVoiceSpeed;
    }

    public void setElectronicVoiceParam(int key, int value) {
        mElectronicKey = key;
        mElectronicValue = value;
    }

    public int getElectronicVoiceKey() {
        return mElectronicKey;
    }

    public int getElectronicVoiceValue() {
        return mElectronicValue;
    }

    public void setAudioMuted(boolean muted) {
        mAudioMuted = muted;
    }

    public boolean getAudioMuted() {
        return mAudioMuted;
    }

    public void setBgImageSelected(int idx) {
        mBgImageSelected = idx;
    }

    public int getBgImageSelected() {
        return mBgImageSelected;
    }
}
