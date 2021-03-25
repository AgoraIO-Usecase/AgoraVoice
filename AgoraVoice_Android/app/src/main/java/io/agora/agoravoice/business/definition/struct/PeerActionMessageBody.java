package io.agora.agoravoice.business.definition.struct;

import java.util.Map;

public class PeerActionMessageBody {
    public static final int ACTION_CMD = 2;

    public int cmd;
    public PeerActionMessageStringWrapper data;

    public static class PeerActionMessageStringWrapper {
        public int action;
        public int processUuid;
        public String fromUserUuid;
        public Map<String, Object> payload;
    }
}
