package io.agora.agoravoice.business.server.retrofit.model.body;

public class CreateRoomBody {
    private String roomName;
    private String backgroundImage;
    private int duration;
    private int audienceLimit;

    public CreateRoomBody(String roomName, String image,
                          int duration, int audienceLimit) {
        this.roomName = roomName;
        this.backgroundImage = image;
        this.duration = duration;
        this.audienceLimit = audienceLimit;
    }
}
