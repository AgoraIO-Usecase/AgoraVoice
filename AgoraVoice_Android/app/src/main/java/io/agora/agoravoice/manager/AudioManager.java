package io.agora.agoravoice.manager;

import io.agora.agoravoice.business.BusinessProxy;
import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;

public class AudioManager {
    public static final int TYPE_VOICE_BEAUTY = 0;
    public static final int TYPE_SOUND_EFFECT = 1;

    public static final int TYPE_API_VOICE_CHANGER = 0;
    public static final int TYPE_API_PRESET = 1;

    public static final int EFFECT_MALE_MAGNETIC = 0;
    public static final int EFFECT_FEMALE_FRESH = 1;
    public static final int EFFECT_FEMALE_VITALITY = 2;

    public static final int EFFECT_MALE_HALL = 3;
    public static final int EFFECT_MALE_LARGE_ROOM = 4;
    public static final int EFFECT_MALE_SMALL_ROOM = 5;
    public static final int EFFECT_FEMALE_HALL = 6;
    public static final int EFFECT_FEMALE_LARGE_ROOM = 7;
    public static final int EFFECT_FEMALE_SMALL_ROOM = 8;

    public static final int EFFECT_TIMBRE_VIGOROUS = 9;
    public static final int EFFECT_TIMBRE_DEEP = 10;
    public static final int EFFECT_TIMBRE_MELLOW = 11;
    public static final int EFFECT_TIMBRE_FALSETTO = 12;
    public static final int EFFECT_TIMBRE_FULL = 13;
    public static final int EFFECT_TIMBRE_CLEAR = 14;
    public static final int EFFECT_TIMBRE_RESOUNDING = 15;
    public static final int EFFECT_TIMBRE_RINGING = 16;

    public static final int EFFECT_SPACING_KTV = 17;
    public static final int EFFECT_SPACING_CONCERT = 18;
    public static final int EFFECT_SPACING_STUDIO = 19;
    public static final int EFFECT_SPACING_PHONOGRAPH = 20;
    public static final int EFFECT_SPACING_STEREO = 21;
    public static final int EFFECT_SPACING_SPACIAL = 22;
    public static final int EFFECT_SPACING_ETHEREAL = 23;
    public static final int EFFECT_SPACING_3D_VOICE = 24;

    public static final int EFFECT_VOICE_CHANGE_UNCLE = 25;
    public static final int EFFECT_VOICE_CHANGE_OLD_MAN = 26;
    public static final int EFFECT_VOICE_CHANGE_BOY = 27;
    public static final int EFFECT_VOICE_CHANGE_SISTER = 28;
    public static final int EFFECT_VOICE_CHANGE_GIRL = 29;
    public static final int EFFECT_VOICE_CHANGE_BAJIE = 30;
    public static final int EFFECT_VOICE_CHANGE_HULK = 31;

    public static final int EFFECT_FLAVOR_RNB = 32;
    public static final int EFFECT_FLAVOR_POP = 33;
    public static final int EFFECT_FLAVOR_ROCK = 34;
    public static final int EFFECT_FLAVOR_HIP_HOP = 35;

    public static final int EFFECT_ELECTRONIC = 36;

    private BusinessProxy mProxy;

    public AudioManager(BusinessProxy proxy) {
        mProxy = proxy;
    }

    public void startBackgroundMusic(String roomId, String fileDir) {
        mProxy.startBackgroundMusic(roomId, fileDir);
    }

    public void stopBackgroundMusic() {
        mProxy.stopBackgroundMusic();
    }

    /**
     * @param volume 0 ~ 100, 100 means the original volume
     *               of the music file
     */
    public void adjustBackgroundMusicVolume(int volume) {
        mProxy.adjustBackgroundMusicVolume(volume);
    }

    public void enableInEarMonitoring(boolean enable) {
        mProxy.enableInEarMonitoring(enable);
    }


    public void enableAudioEffect(int type) {
        mProxy.enableAudioEffect(type);
    }

    public void disableAudioEffect() {
        mProxy.disableAudioEffect();
    }

    /**
     * Set the speed for 3D human voice, only takes effect
     * when the 3D human voice effect is enabled.
     * @param speed between 1 ~ 60
     */
    public void set3DHumanVoiceParams(int speed) {
        mProxy.set3DHumanVoiceParams(speed);
    }

    /**
     * Set params for electronic effect, only takes effect
     * when this sound effect is enabled.
     * @param key
     * @param value
     */
    public void setElectronicParams(int key, int value) {
        mProxy.setElectronicParams(key, value);
    }

    public void enableLocalAudio() {
        mProxy.enableLocalAudio();
    }

    public void disableLocalAudio() {
        mProxy.disableLocalAudio();
    }

    public void enableRemoteAudio(String userId, boolean enabled) {
        mProxy.enableRemoteAudio(userId, enabled);
    }

    public void muteLocalAudio(boolean muted) {
        mProxy.muteLocalAudio(muted);
    }

    public void muteRemoteAudio(String userId, boolean muted) {
        mProxy.muteRemoteAudio(userId, muted);
    }
}
