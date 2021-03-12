package io.agora.agoravoice.business.definition.struct;

public class InvitationMessage {
    public int cmd;
    public InvitationBody data;

    public static class InvitationBody {
        public int processUuid;
        public int action;
        public FromUser fromUser;
        public Payload payload;
    }

    public static class FromUser {
        public String userUuid;
        public String userName;
        public String role;
    }

    public static class Payload {
        public int no;
        public int type;
    }
}

