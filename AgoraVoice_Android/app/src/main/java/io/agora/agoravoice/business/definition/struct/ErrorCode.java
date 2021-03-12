package io.agora.agoravoice.business.definition.struct;

import io.agora.agoravoice.R;

public class ErrorCode {
    public static final int ERROR_ROOM_NOT_EXIST = 20404100;
    public static final int ERROR_ROOM_MAX_USER = 20403001;

    public static final int ERROR_ROOM_END = 1301003;
    public static final int ERROR_SEAT_TAKEN = 1301006;

    public static int getErrorMessageRes(int code) {
        switch (code) {
            case ERROR_ROOM_MAX_USER: return R.string.error_room_max_user;
            case ERROR_SEAT_TAKEN: return R.string.error_seat_taken;
            default: return R.string.error_no;
        }
    }
}
