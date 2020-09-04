package io.agora.agoravoice.utils;

import io.agora.agoravoice.R;

public class PortraitUtil {
    private static final int[] PORTRAIT_RES = {
            R.drawable.portrait_1,
            R.drawable.portrait_2,
            R.drawable.portrait_3,
            R.drawable.portrait_4,
            R.drawable.portrait_5,
            R.drawable.portrait_6,
            R.drawable.portrait_7,
            R.drawable.portrait_8,
            R.drawable.portrait_9,
    };

    public static int getPortraitResByIndex(int index) {
        int idx = index;
        if (index < 0 || index >= PORTRAIT_RES.length) {
            idx = 0;
        }

        return PORTRAIT_RES[idx];
    }

    public static int getPortraitCount() {
        return PORTRAIT_RES.length;
    }
}
