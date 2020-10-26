package io.agora.agoravoice.business.definition.struct;

public class SeatStateData {
    public int no;
    public String userId;
    public String userName;
    public int state;

    public SeatStateData(int no, String userId, String userName, int state) {
        this.no = no;
        this.userId = userId;
        this.userName = userName;
        this.state = state;
    }
}
