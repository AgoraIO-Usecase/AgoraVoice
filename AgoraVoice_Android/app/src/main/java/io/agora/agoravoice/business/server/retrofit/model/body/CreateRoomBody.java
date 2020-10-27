package io.agora.agoravoice.business.server.retrofit.model.body;

public class CreateRoomBody {
    private String roomName;
    private String backgroundImage;

    public CreateRoomBody(String roomName, String image) {
        this.roomName = roomName;
        this.backgroundImage = image;
    }
}
