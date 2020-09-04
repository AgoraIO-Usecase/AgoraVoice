package io.agora.agoravoice.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.RelativeLayout;

import io.agora.agoravoice.R;
import io.agora.agoravoice.ui.views.RoomMessageList;
import io.agora.agoravoice.ui.views.RtcStatsView;
import io.agora.agoravoice.ui.views.actionsheets.ActionSheetManager;
import io.agora.agoravoice.ui.views.actionsheets.BackgroundActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.GiftActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.MusicActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.SoundEffectActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.ToolActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.VoiceBeautyActionSheet;
import io.agora.agoravoice.ui.views.bottombar.AbsBottomBar;
import io.agora.agoravoice.ui.views.bottombar.ChatRoomBottomBar;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.RoomBgUtil;


public class ChatRoomActivity extends AbsLiveActivity implements View.OnClickListener{
    private RelativeLayout mBackground;

    // Room basic info
    private String mRoomName;
    private int mBackgroundImageRes;
    private Const.Role mCurrentRole = Const.Role.audience;

    private ChatRoomBottomBar mBottomBar;
    private RtcStatsView mStatView;
    private RoomMessageList mMessageList;

    private AbsBottomBar.BottomBarListener mBottomBarListener = new AbsBottomBar.BottomBarListener() {
        @Override
        public void onTextEditClicked() {

        }

        @Override
        public void onButtonClicked(Const.Role role, View view, int index) {
            if (role == Const.Role.owner ||
                role == Const.Role.host) {
                switch (index) {
                    case 0:
                        ToolActionSheet toolActionSheet = (ToolActionSheet)
                            createActionSheet(ActionSheetManager.ActionSheet.tool);
                        toolActionSheet.setRole(mCurrentRole);
                        toolActionSheet.setToolActionListener(mToolActionListener);
                        showActionSheet(toolActionSheet, true);
                        break;
                    case 1:
                        SoundEffectActionSheet effectActionSheet = (SoundEffectActionSheet)
                                createActionSheet(ActionSheetManager.ActionSheet.sound_effect);
                        showActionSheet(effectActionSheet, true);
                        break;
                    case 2:
                        VoiceBeautyActionSheet voiceBeautyActionSheet = (VoiceBeautyActionSheet)
                                createActionSheet(ActionSheetManager.ActionSheet.voice_beauty);
                        showActionSheet(voiceBeautyActionSheet, true);
                        break;
                    case 3: break;
                }
            } else if (role == Const.Role.audience) {
                if (index == 0) {
                    ToolActionSheet toolActionSheet = (ToolActionSheet)
                            createActionSheet(ActionSheetManager.ActionSheet.tool);
                    toolActionSheet.setRole(mCurrentRole);
                    toolActionSheet.setToolActionListener(mToolActionListener);
                    showActionSheet(toolActionSheet, true);
                } else if (index == 1) {
                    GiftActionSheet giftActionSheet = (GiftActionSheet)
                            createActionSheet(ActionSheetManager.ActionSheet.gift);
                    giftActionSheet.setGiftActionListener(mGiftActionListener);
                    showActionSheet(giftActionSheet, true);
                }
            }
        }
    };

    private GiftActionSheet.GiftActionListener mGiftActionListener = index -> {
        closeActionSheet();
    };

    private BackgroundActionSheet.BackgroundActionSheetListener mBackgroundListener =
            new BackgroundActionSheet.BackgroundActionSheetListener() {
                @Override
                public void onBackgroundPicSelected(int index, int res) {

                }

                @Override
                public void onBackgroundBackClicked() {

                }
            };

    private ToolActionSheet.ToolActionListener mToolActionListener = (role, view, index) -> {
        switch (role) {
            case owner:
                switch (index) {
                    case 0:   // in-ear monitor
                        break;
                    case 1:
                        MusicActionSheet musicActionSheet = (MusicActionSheet)
                                createActionSheet(ActionSheetManager.ActionSheet.music);
                        showActionSheet(musicActionSheet, false);
                        break;
                    case 2:
                        BackgroundActionSheet backgroundActionSheet = (BackgroundActionSheet)
                                createActionSheet(ActionSheetManager.ActionSheet.background);
                        backgroundActionSheet.setOnBackgroundActionListener(mBackgroundListener);
                        showActionSheet(backgroundActionSheet, false);
                        break;
                    case 3:
                        showStatsView();
                        break;
                }
                break;
            case host:
                switch (index) {
                    case 0:   // in-ear monitor
                        break;
                    case 1:
                        showStatsView();
                        break;
                }
                break;
            case audience:
                if (index == 0) showStatsView();
                break;
        }
    };

    private void showStatsView() {
        if (mStatView != null) mStatView.show();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_room);

        getIntentInfo(getIntent());
        initView();
    }

    private void getIntentInfo(Intent intent) {
        mRoomName = intent.getStringExtra(Const.KEY_ROOM_NAME);
        int bgIndex = intent.getIntExtra(Const.KEY_BACKGROUND, 0);
        mBackgroundImageRes = RoomBgUtil.getRoomBgPicRes(bgIndex);
    }

    private void initView() {
        mBackground = findViewById(R.id.chat_room_background_layout);
        initBackground();

        mBottomBar = findViewById(R.id.chat_room_bottom_bar);
        mBottomBar.setBottomBarListener(mBottomBarListener);

        mStatView = findViewById(R.id.rtc_stats_view);
        mStatView.setCloseListener(this);

        mMessageList = findViewById(R.id.chat_room_message_list);
        mMessageList.addMessage(RoomMessageList.MSG_TYPE_CHAT, "me", "test message`");

        findViewById(R.id.chat_room_exit_btn).setOnClickListener(this);
    }

    private void initBackground() {
        mBackground.setBackgroundResource(mBackgroundImageRes);
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        RelativeLayout topLayout = findViewById(R.id.chat_room_top_bar);
        if (topLayout != null) {
            RelativeLayout.LayoutParams params =
                    (RelativeLayout.LayoutParams) topLayout.getLayoutParams();
            params.topMargin += systemBarHeight;
            topLayout.setLayoutParams(params);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.chat_room_exit_btn:
                //TODO for test
                mCurrentRole = Const.Role.owner;
                mBottomBar.setRole(mCurrentRole);
                break;
            case R.id.stats_close_btn:
                closeStatsView();
                break;
        }
    }

    private void closeStatsView() {
        if (mStatView != null) mStatView.dismiss();
    }
}
