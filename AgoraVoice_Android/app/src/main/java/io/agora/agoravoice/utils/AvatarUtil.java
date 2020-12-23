package io.agora.agoravoice.utils;

import io.agora.agoravoice.R;

public class AvatarUtil {
    private static final int[] AVATAR_RES = {
            R.drawable.avatar_1,
            R.drawable.avatar_2,
            R.drawable.avatar_3,
            R.drawable.avatar_4,
            R.drawable.avatar_5,
            R.drawable.avatar_6,
            R.drawable.avatar_7,
            R.drawable.avatar_8,
            R.drawable.avatar_9,
    };

    public static int getAvatarResByIndex(int index) {
        int idx = index;
        if (index < 0 || index >= AVATAR_RES.length) {
            idx = 0;
        }

        return AVATAR_RES[idx];
    }

    public static int getAvatarCount() {
        return AVATAR_RES.length;
    }
}
