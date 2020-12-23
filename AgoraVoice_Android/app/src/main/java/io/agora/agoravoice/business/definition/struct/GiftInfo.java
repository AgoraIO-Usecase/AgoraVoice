package io.agora.agoravoice.business.definition.struct;

public class GiftInfo {
    int giftId;
    String giftName;
    String thumbnail;
    String animation;
    int res;
    int point;

    public GiftInfo(int id, String name, int res, int point) {
        this.giftId = id;
        this.giftName = name;
        this.res = res;
        this.point = point;
    }

    public int getGiftId() {
        return giftId;
    }

    public String getGiftName() {
        return giftName;
    }

    public String getThumbnail() {
        return thumbnail;
    }

    public String getAnimation() {
        return animation;
    }

    public int getPoint() {
        return point;
    }

    public int getRes() {
        return res;
    }
}
