package io.agora.agoravoice.utils;

import io.agora.agoravoice.R;

public class Const {
    public static final String KEY_SCENE_TYPE_NAME = "key-scene-type-name";
    public static final String KEY_BACKGROUND = "key-room-background";
    public static final String KEY_ROOM_NAME = "key-room-name";
    public static final String KEY_ROOM_ID = "key-room-id";

    public static final String SP_NAME = "agora-voice";

    public static final String KEY_USER_ID = "key-user-id";
    public static final String KEY_USER_NAME = "key-user-name";
    public static final String KEY_UID = "key-uid";
    public static final String KEY_USER_ROLE = "key-user-role";
    public static final String KEY_TOKEN = "key-token";

    public static final String LOG_PREFIX = "agoravoice";
    public static final int LOG_MAX_FILES = 5;
    public static final String LOG_TAG = "AgoraVoice";

    // By default the app log keeps for 5 days before being destroyed
    public static final long LOG_DURATION = 1000 * 60 * 24 * 5;

    public static final String LOG_APP_SECRET = "";

    public static final long APP_LOG_SIZE = 1 << 30;

    public static final int ROOM_DURATION = 10;
    public static final int ROOM_MAX_AUDIENCE = 10;

    public static final int ROOM_LEAVE_TIMEOUT = 1;
    public static final int ROOM_LEAVE_OWNER = 2;

    public enum Role {
        owner, host, audience;

        public static Role getRole(int role) {
            switch (role) {
                case 0: return owner;
                case 1: return host;
                default: return audience;
            }
        }

        public static String toString(Role role) {
            switch (role) {
                case owner: return "owner";
                case host: return "host";
                default: return "audience";
            }
        }

        public static Role fromString(String role) {
            switch (role) {
                case "owner": return owner;
                case "host": return host;
                default: return audience;
            }
        }
    }

    public static final int[] AVATAR_RES = {
            R.drawable.avatar_1,
            R.drawable.avatar_2,
            R.drawable.avatar_3,
            R.drawable.avatar_4,
            R.drawable.avatar_5,
            R.drawable.avatar_6,
            R.drawable.avatar_7,
            R.drawable.avatar_8,
            R.drawable.avatar_9,
    };

    public static final int ERR_OK = 0;
    public static final int ERR_USER_UNKNOWN = -1;
    public static final int ERR_REPEAT_INVITE = -2;
    public static final int ERR_REPEAT_APPLY = -3;
    public static final int ERR_NOT_INITIALIZED = -4;
}
