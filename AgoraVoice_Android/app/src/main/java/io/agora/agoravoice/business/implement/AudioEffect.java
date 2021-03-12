package io.agora.agoravoice.business.implement;

import java.util.Locale;

public class AudioEffect {
    public static class AudioEffectParam {
        public static final int TYPE_REVERB = 1;
        public static final int TYPE_CHANGER = 2;
        public static final int TYPE_BEAUTY = 3;
        public static final int TYPE_3D_VOICE = 4;
        public static final int TYPE_STEREO = 5;
        public static final int TYPE_SING = 6;

        private static final String FORMAT_PRESET = "che.audio.morph.reverb_preset";
        private static final String FORMAT_CHANGE = "che.audio.morph.voice_changer";
        private static final String FORMAT_BEAUTY = "che.audio.morph.beauty_voice";
        private static final String FORMAT_3D_SPEED = "che.audio.morph.threedim_voice";
        private static final String FORMAT_STEREO = "che.audio.morph.virtual_stereo";
        private static final String FORMAT_SING = "che.audio.morph.beauty_sing";
        private static final String FORMAT_PARAM = "{\"%s\":%d}";
        private static final String FORMAT_PARAM_SING = "{\"%s\":{\"key\":%d,\"value\":1}}";

        public final int type;
        public final int value;

        public AudioEffectParam(int type, int value) {
            this.type = type;
            this.value = value;
        }

        public String toParameter() {
            return String.format(Locale.getDefault(),
                    this.type == TYPE_SING ? FORMAT_PARAM_SING : FORMAT_PARAM,
                    getParameterKeyByType(this.type), this.value);
        }

        private String getParameterKeyByType(int type) {
            switch (type) {
                case TYPE_REVERB: return FORMAT_PRESET;
                case TYPE_CHANGER: return FORMAT_CHANGE;
                case TYPE_BEAUTY: return FORMAT_BEAUTY;
                case TYPE_3D_VOICE: return FORMAT_3D_SPEED;
                case TYPE_STEREO: return FORMAT_STEREO;
                case TYPE_SING: return FORMAT_SING;
                default: return FORMAT_PARAM;
            }
        }
    }

    public static final AudioEffectParam[] AUDIO_EFFECT_PARAMS = {
            // Chat voice beauty
            new AudioEffectParam(AudioEffectParam.TYPE_BEAUTY, 1),  // Male magnetic
            new AudioEffectParam(AudioEffectParam.TYPE_BEAUTY, 2),  // Female fresh
            new AudioEffectParam(AudioEffectParam.TYPE_BEAUTY, 3),  // Female vitality

            // Sing voice beauty
            new AudioEffectParam(AudioEffectParam.TYPE_SING, 1),  // Beauty sing male
            new AudioEffectParam(AudioEffectParam.TYPE_SING, 1),
            new AudioEffectParam(AudioEffectParam.TYPE_SING, 1),
            new AudioEffectParam(AudioEffectParam.TYPE_SING, 2),  // Beauty sing female
            new AudioEffectParam(AudioEffectParam.TYPE_SING, 2),
            new AudioEffectParam(AudioEffectParam.TYPE_SING, 2),

            // Timbre
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 7),  // Vigorous
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 8),  // Deep
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 9),  // Mellow
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 10), // Falsetto
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 11),  // Full
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 12), // Clear
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 13), // Resounding
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 14), // Ringing

            // Spacing
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 1),    // KTV
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 2),    // Concert
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 3),    // Studio
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 4),    // Phonograph
            new AudioEffectParam(AudioEffectParam.TYPE_STEREO, 1),    // Virtual stereo
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 15),  // Spacial
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 5),   // Ethereal

            // Simply setting to default speed (10) will enable 3D voice effect
            new AudioEffectParam(AudioEffectParam.TYPE_3D_VOICE, 10),  // 3D voice

            // Voice Change
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 3), // Uncle
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 1), // Old man
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 2), // Baby boy
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 4), // Sister
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 3), // Little girl
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 4), // Bajie
            new AudioEffectParam(AudioEffectParam.TYPE_CHANGER, 6), // Hulk

            // Flavor
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 12),  // Hip hop
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 6),   // Popular
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 11),  // Rock and roll
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 7),   // RNB

            // Electronic
            new AudioEffectParam(AudioEffectParam.TYPE_REVERB, 12),  // Undefined
    };
}
