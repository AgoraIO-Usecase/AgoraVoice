package io.agora.agoravoice.ui.views.bottombar;

import java.util.HashMap;
import java.util.Map;

import io.agora.agoravoice.utils.Const;

public class BottomBarConfig {
    public Map<Integer, BottomBarButtonConfigWithRole> buttonConfigs = new HashMap<>();

    public static class BottomBarButtonConfigWithRole {
        Map<Const.Role, BottomBarButtonConfig> configs = new HashMap<>();
    }

    public static class BottomBarButtonConfig {
        public int index;
        public int icon;
        public boolean show;
        public boolean activated = true;

        public BottomBarButtonConfig(int index, int icon, boolean show) {
            this.index = index;
            this.icon = icon;
            this.show = show;
        }
    }
}
