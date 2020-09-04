package io.agora.agoravoice.utils;

import io.agora.agoravoice.R;

public class RoomBgUtil {
    private static final int[] PREVIEW_ICON_RES = {
            R.drawable.room_bg_prev_1,
            R.drawable.room_bg_prev_2,
            R.drawable.room_bg_prev_3,
            R.drawable.room_bg_prev_4,
            R.drawable.room_bg_prev_5,
            R.drawable.room_bg_prev_6,
            R.drawable.room_bg_prev_7,
            R.drawable.room_bg_prev_8,
            R.drawable.room_bg_prev_9,
    };

    private static final int[] BG_PIC_RES = {
            R.drawable.room_bg_big_1,
            R.drawable.room_bg_big_2,
            R.drawable.room_bg_big_3,
            R.drawable.room_bg_big_4,
            R.drawable.room_bg_big_5,
            R.drawable.room_bg_big_6,
            R.drawable.room_bg_big_7,
            R.drawable.room_bg_big_8,
            R.drawable.room_bg_big_9,
    };

    public static int getRoomBgPreviewRes(int index) {
         return 0 <= index && index < PREVIEW_ICON_RES.length ? PREVIEW_ICON_RES[index] : -1;
    }

    public static int getRoomBgPicRes(int index) {
        return 0 <= index && index < BG_PIC_RES.length ? BG_PIC_RES[index] : -1;
    }

    public static int totalCount() {
        return PREVIEW_ICON_RES.length;
    }
}
