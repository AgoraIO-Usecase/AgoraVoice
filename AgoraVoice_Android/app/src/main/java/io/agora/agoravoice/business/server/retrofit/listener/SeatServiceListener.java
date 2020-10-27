package io.agora.agoravoice.business.server.retrofit.listener;

public interface SeatServiceListener {
    void onSeatBehaviorSuccess(String roomId, int type, String userId, String userName, int no, int reason, String message);

    void onSeatBehaviorFail(int type, String userId, String userName, int no, int reason, String message);

    void onSeatStateChanged(int no, int state);

    void onSeatStateChangeFail(int no, int state, int reason, String message);
}
