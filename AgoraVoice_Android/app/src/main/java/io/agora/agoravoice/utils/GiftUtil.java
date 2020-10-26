package io.agora.agoravoice.utils;

import android.content.Context;

import io.agora.agoravoice.R;
import io.agora.agoravoice.ui.activities.ChatRoomActivity;
import io.agora.agoravoice.ui.views.GiftAnimWindow;

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

    public static int parseGiftIndexFromId(String id) {
        try {
            int idNumber = Integer.parseInt(id);
            if (0 <= idNumber && idNumber < GIFT_ANIM_RES.length) {
                return idNumber;
            } else {
                return -1;
            }
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    public static String getGiftIdFromIndex(int index) {
        if (index < 0 || index >= GIFT_ANIM_RES.length) return "";
        return index + "";
    }

    public static void showGiftAnimation(Context context, int index) {
        if (index < 0 || index >= GIFT_ANIM_RES.length) return;
        GiftAnimWindow window = new GiftAnimWindow(context, R.style.gift_anim_window);
        window.setAnimResource(GiftUtil.getGiftAnimRes(index));
        window.show();
    }
}
