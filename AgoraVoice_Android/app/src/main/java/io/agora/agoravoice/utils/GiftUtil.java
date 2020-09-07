package io.agora.agoravoice.utils;

import io.agora.agoravoice.R;

public class GiftUtil {
    public static int[] GIFT_ICON_RES = {
            R.drawable.gift_01_bell,
            R.drawable.gift_02_icecream,
            R.drawable.gift_03_wine,
            R.drawable.gift_04_cake,
            R.drawable.gift_05_ring,
            R.drawable.gift_06_watch,
            R.drawable.gift_07_diamond,
            R.drawable.gift_08_rocket
    };

    public static final int[] GIFT_ANIM_RES = {
            R.drawable.gift_anim_bell,
            R.drawable.gift_anim_icecream,
            R.drawable.gift_anim_wine,
            R.drawable.gift_anim_cake,
            R.drawable.gift_anim_ring,
            R.drawable.gift_anim_watch,
            R.drawable.gift_anim_diamond,
            R.drawable.gift_anim_rocket
    };

    public static int getGiftAnimRes(int id) {
        return GIFT_ANIM_RES[id];
    }
}
