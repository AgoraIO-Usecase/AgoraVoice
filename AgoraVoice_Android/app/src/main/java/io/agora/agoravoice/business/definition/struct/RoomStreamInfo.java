package io.agora.agoravoice.business.definition.struct;

public class RoomStreamInfo {
    public String userId;
    public String userName;
    public String streamId;
    public String streamName;
    public boolean enableVideo;
    public boolean enableAudio;
    public boolean isOwner;

    public static RoomStreamInfo copy(RoomStreamInfo info) {
        RoomStreamInfo ret = new RoomStreamInfo();
        if (info != null) {
            ret.userId = info.userId;
            ret.userName = info.userName;
            ret.streamId = info.streamId;
            ret.streamName = info.streamName;
            ret.enableAudio = info.enableAudio;
            ret.enableVideo = info.enableVideo;
            ret.isOwner = info.isOwner;
        }
        return ret;
    }

    public void enableAudio(boolean enabled) {
        enableAudio = enabled;
    }

    public RoomStreamInfo(String userId, String userName,
                          String streamId, String streamName,
                          boolean enableAudio, boolean enableVideo, boolean isOwner) {
        this.userId = userId;
        this.userName = userName;
        this.streamId = streamId;
        this.streamName = streamName;
        this.enableAudio = enableAudio;
        this.enableVideo = enableVideo;
        this.isOwner = isOwner;
    }

    public RoomStreamInfo() {

    }
}
