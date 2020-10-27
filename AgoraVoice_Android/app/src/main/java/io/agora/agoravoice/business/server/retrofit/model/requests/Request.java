package io.agora.agoravoice.business.server.retrofit.model.requests;

public class Request {
    public static final int CREATE_USER = 0;
    public static final int EDIT_USER = 1;
    public static final int LOGIN = 2;

    public static final int CHECK_VERSION = 3;
    public static final int MUSIC_LIST = 4;
    public static final int GIFT_LIST = 5;

    public static final int CREATE_ROOM = 6;
    public static final int ROOM_LIST = 7;
    public static final int ENTER_ROOM = 8;
    public static final int LEAVE_ROOM = 9;

    public static final int SEND_GIFT = 10;
    public static final int MODIFY_ROOM = 11;
    public static final int SEND_CHAT = 12;

    public static int toBusinessType(int type) {
        return type;
    }
}
