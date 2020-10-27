package io.agora.agoravoice.business.definition.struct;

public class UserProfile {
    private String mUserToken;
    private String mRtmToken;
    private String mUserId;
    private String mUserName;

    public String getUserToken() {
        return mUserToken;
    }

    public void setUserToken(String mToken) {
        this.mUserToken = mToken;
    }

    public String getRtmToken() {
        return mRtmToken;
    }

    public void setRtmToken(String mRtmToken) {
        this.mRtmToken = mRtmToken;
    }

    public String getUserId() {
        return mUserId;
    }

    public void setUserId(String mUserId) {
        this.mUserId = mUserId;
    }

    public String getUserName() {
        return mUserName;
    }

    public void setUserName(String mUserName) {
        this.mUserName = mUserName;
    }
}
