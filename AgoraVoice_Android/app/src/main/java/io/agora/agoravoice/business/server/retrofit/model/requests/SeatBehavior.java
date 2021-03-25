package io.agora.agoravoice.business.server.retrofit.model.requests;

public class SeatBehavior {
    public static final int INVITE = 1;
    public static final int APPLY = 2;
    public static final int APPLY_REJECT = 3;
    public static final int INVITE_REJECT = 4;
    public static final int APPLY_ACCEPT = 5;
    public static final int INVITE_ACCEPT = 6;
    public static final int FORCE_LEAVE = 7;
    public static final int LEAVE = 8;
    public static final int INVITE_CANCEL = -1;
}
