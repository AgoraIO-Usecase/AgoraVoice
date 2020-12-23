package io.agora.agoravoice.business.implement.edu;

import java.util.Locale;

import io.agora.rtc.Constants;
import io.agora.rte.RteEngineImpl;

class AudioEffect {
    private static final int TYPE_VOICE_CHANGE = 0;
    private static final int TYPE_VOICE_REVERB = 1;

    private static final int[][] AUDIO_EFFECT_PARAMS = {
            // Chat voice beauty
            { TYPE_VOICE_CHANGE, Constants.GENERAL_BEAUTY_VOICE_MALE_MAGNETIC },
            { TYPE_VOICE_CHANGE, Constants.GENERAL_BEAUTY_VOICE_FEMALE_FRESH },
            { TYPE_VOICE_CHANGE, Constants.GENERAL_BEAUTY_VOICE_FEMALE_VITALITY },

            // Sing voice beauty
            { TYPE_VOICE_CHANGE, Constants.GENERAL_BEAUTY_SING_MALE },
            { TYPE_VOICE_CHANGE, Constants.GENERAL_BEAUTY_SING_MALE },
            { TYPE_VOICE_CHANGE, Constants.GENERAL_BEAUTY_SING_MALE },
            { TYPE_VOICE_CHANGE, Constants.GENERAL_BEAUTY_SING_FEMALE },
            { TYPE_VOICE_CHANGE, Constants.GENERAL_BEAUTY_SING_FEMALE },
            { TYPE_VOICE_CHANGE, Constants.GENERAL_BEAUTY_SING_FEMALE },

            // Timbre
            { TYPE_VOICE_CHANGE, Constants.VOICE_BEAUTY_VIGOROUS },
            { TYPE_VOICE_CHANGE, Constants.VOICE_BEAUTY_DEEP },
            { TYPE_VOICE_CHANGE, Constants.VOICE_BEAUTY_MELLOW },
            { TYPE_VOICE_CHANGE, Constants.VOICE_BEAUTY_FALSETTO },
            { TYPE_VOICE_CHANGE, Constants.VOICE_BEAUTY_FULL },
            { TYPE_VOICE_CHANGE, Constants.VOICE_BEAUTY_CLEAR },
            { TYPE_VOICE_CHANGE, Constants.VOICE_BEAUTY_RESOUNDING },
            { TYPE_VOICE_CHANGE, Constants.VOICE_BEAUTY_RINGING },

            // Spacing
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_FX_KTV },
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_FX_VOCAL_CONCERT },
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_FX_STUDIO },
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_FX_PHONOGRAPH },
            { TYPE_VOICE_REVERB, Constants.AUDIO_VIRTUAL_STEREO },
            { TYPE_VOICE_CHANGE, Constants.VOICE_BEAUTY_SPACIAL },
            { TYPE_VOICE_CHANGE, Constants.VOICE_CHANGER_ETHEREAL },
            { TYPE_VOICE_REVERB, Constants.AUDIO_THREEDIM_VOICE },

            // Voice Change
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_FX_UNCLE },
            { TYPE_VOICE_CHANGE, Constants.VOICE_CHANGER_OLDMAN },
            { TYPE_VOICE_CHANGE, Constants.VOICE_CHANGER_BABYBOY },
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_FX_SISTER },
            { TYPE_VOICE_CHANGE, Constants.VOICE_CHANGER_BABYGIRL },
            { TYPE_VOICE_CHANGE, Constants.VOICE_CHANGER_ZHUBAJIE },
            { TYPE_VOICE_CHANGE, Constants.VOICE_CHANGER_HULK },

            // Flavor
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_FX_RNB },
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_FX_POPULAR },
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_ROCK },
            { TYPE_VOICE_REVERB, Constants.AUDIO_REVERB_HIPHOP },

            // Electronic
            { TYPE_VOICE_REVERB, Constants.AUDIO_ELECTRONIC_VOICE }
    };

    public static void startAudioMixing(String roomId, String filePath) {
        // play background music indefinitely
        RteEngineImpl.INSTANCE.startAudioMixing(filePath, false, false, -1);
    }

    public static void stopAudioMixing() {
        RteEngineImpl.INSTANCE.stopAudioMixing();
    }

    public static void adjustAudioMixingVolume(int volume) {
        RteEngineImpl.INSTANCE.adjustAudioMixingVolume(volume);
    }

    public static void enableInEarMonitoring(boolean enable) {
        RteEngineImpl.INSTANCE.enableInEarMonitoring(enable);
    }

    /**
     * Enable a certain audio effect
     * @param type defined in AudioManager, actually acts as
     *             the index of the parameter array
     */
    public static void enableAudioEffect(int type) {
        if (type < 0 || type >= AUDIO_EFFECT_PARAMS.length) return;

        int[] param = AUDIO_EFFECT_PARAMS[type];
        int api = param[0];
        int value = param[1];
        if (api == TYPE_VOICE_CHANGE) {
            RteEngineImpl.INSTANCE.setLocalVoiceChanger(value);
        } else if (api == TYPE_VOICE_REVERB) {
            RteEngineImpl.INSTANCE.setLocalVoiceReverbPreset(value);
        }
    }

    public static void disableAudioEffect() {
        RteEngineImpl.INSTANCE.setLocalVoiceChanger(Constants.VOICE_CHANGER_OFF);
        RteEngineImpl.INSTANCE.setLocalVoiceReverbPreset(Constants.AUDIO_REVERB_OFF);
    }

    public static void set3DHumanVoiceParams(int speed) {
        String format = "{\"che.audio.morph.threedim_voice\":%d}";
        String param = String.format(Locale.getDefault(),format, speed);
        RteEngineImpl.INSTANCE.setRtcParams(param);
    }

    public static void setElectronicParams(int key, int value) {
        String format = "{\"che.audio.morph.electronic_voice\":{\"key\":%d,\"value\":%d}}";
        String param = String.format(Locale.getDefault(), format, key, value);
        RteEngineImpl.INSTANCE.setRtcParams(param);
    }
}
