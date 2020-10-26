package io.agora.agoravoice.ui.views.bottombar;

import android.content.Context;
import android.util.AttributeSet;

import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.Const;

public class ChatRoomBottomBar extends AbsBottomBar {
    public ChatRoomBottomBar(Context context) {
        super(context);
    }

    public ChatRoomBottomBar(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public BottomBarConfig onGetConfig() {
        BottomBarConfig config = new BottomBarConfig();

        BottomBarConfig.BottomBarButtonConfigWithRole configWithRole1 =
                new BottomBarConfig.BottomBarButtonConfigWithRole();

        // More button will always show for all roles
        BottomBarConfig.BottomBarButtonConfig barConfig1
                = new BottomBarConfig.BottomBarButtonConfig(0, R.drawable.icon_more,  true);
        configWithRole1.configs.put(Const.Role.owner, barConfig1);
        configWithRole1.configs.put(Const.Role.host, barConfig1);
        configWithRole1.configs.put(Const.Role.audience, barConfig1);
        config.buttonConfigs.put(0, configWithRole1);

        // The 2nd button show sound effect icon for owner and audience,
        // and show gift icon for audience
        BottomBarConfig.BottomBarButtonConfigWithRole configWithRole2 =
                new BottomBarConfig.BottomBarButtonConfigWithRole();
        BottomBarConfig.BottomBarButtonConfig buttonConfig2CanSpeak =
                new BottomBarConfig.BottomBarButtonConfig(1, R.drawable.icon_sound_effect,  true);
        configWithRole2.configs.put(Const.Role.owner, buttonConfig2CanSpeak);
        configWithRole2.configs.put(Const.Role.host, buttonConfig2CanSpeak);

        BottomBarConfig.BottomBarButtonConfig buttonConfig2Audience =
                new BottomBarConfig.BottomBarButtonConfig(1, R.drawable.icon_gift,  true);
        configWithRole2.configs.put(Const.Role.audience, buttonConfig2Audience);
        config.buttonConfigs.put(1, configWithRole2);

        // The 3rd button is hidden for audience, and show
        // voice beauty button for owner and hosts
        BottomBarConfig.BottomBarButtonConfigWithRole configWithRole3 =
                new BottomBarConfig.BottomBarButtonConfigWithRole();

        BottomBarConfig.BottomBarButtonConfig buttonConfig3CanSpeak =
                new BottomBarConfig.BottomBarButtonConfig(2, R.drawable.icon_voice_beauty,  true);
        configWithRole3.configs.put(Const.Role.owner, buttonConfig3CanSpeak);
        configWithRole3.configs.put(Const.Role.host, buttonConfig3CanSpeak);

        BottomBarConfig.BottomBarButtonConfig buttonConfig3Hidden =
                new BottomBarConfig.BottomBarButtonConfig(2, 0,  false);
        configWithRole3.configs.put(Const.Role.audience, buttonConfig3Hidden);
        config.buttonConfigs.put(2, configWithRole3);

        // The 4th button is also hidden for audience, and show
        // mute icon for owner and hosts
        BottomBarConfig.BottomBarButtonConfigWithRole configWithRole4 =
                new BottomBarConfig.BottomBarButtonConfigWithRole();
        BottomBarConfig.BottomBarButtonConfig buttonConfig4CanSpeak =
                new BottomBarConfig.BottomBarButtonConfig(3, R.drawable.chat_room_bottom_bar_mic_icon,  true);
        configWithRole4.configs.put(Const.Role.owner, buttonConfig4CanSpeak);
        configWithRole4.configs.put(Const.Role.host, buttonConfig4CanSpeak);

        BottomBarConfig.BottomBarButtonConfig buttonConfig4Audience =
                new BottomBarConfig.BottomBarButtonConfig(3, 0,  false);
        configWithRole4.configs.put(Const.Role.audience, buttonConfig4Audience);
        config.buttonConfigs.put(3, configWithRole4);

        return config;
    }

    public void setEnableAudio(boolean enableAudio) {
        Const.Role role = getRole();
        if (role == Const.Role.owner || role == Const.Role.host) {
           if (buttons[3].isShown()) {
               buttons[3].setActivated(enableAudio);
           }
        }
    }
}
