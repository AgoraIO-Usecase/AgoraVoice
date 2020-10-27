package io.agora.agoravoice.business.definition.struct;

import io.agora.agoravoice.R;

public class ErrorCode {
    public static final int ERROR_ROOM_MAX_USER = 7;

    public static final int ERROR_SEAT_TAKEN = 1301006;

    public static int getErrorMessageRes(int code) {
        switch (code) {
            case ERROR_ROOM_MAX_USER: return R.string.error_room_max_user;
            case ERROR_SEAT_TAKEN: return R.string.error_seat_taken;
            default: return R.string.error_no;
        }
    }
}
