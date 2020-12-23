package io.agora.agoravoice.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.elvishew.xlog.XLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import io.agora.agoravoice.R;
import io.agora.agoravoice.business.definition.interfaces.RoomEventListener;
import io.agora.agoravoice.business.definition.struct.ErrorCode;
import io.agora.agoravoice.business.definition.struct.GiftSendInfo;
import io.agora.agoravoice.business.definition.struct.RoomStreamInfo;
import io.agora.agoravoice.business.definition.struct.RoomUserInfo;
import io.agora.agoravoice.business.definition.struct.SeatStateData;
import io.agora.agoravoice.business.server.retrofit.model.requests.SeatBehavior;
import io.agora.agoravoice.manager.AudioManager;
import io.agora.agoravoice.manager.InvitationManager;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.ui.views.ChatRoomHostPanel;
import io.agora.agoravoice.ui.views.CropBackgroundRelativeLayout;
import io.agora.agoravoice.ui.views.MessageEditLayout;
import io.agora.agoravoice.ui.views.RoomMessageList;
import io.agora.agoravoice.ui.views.RoomUserActionView;
import io.agora.agoravoice.ui.views.RtcStatsView;
import io.agora.agoravoice.ui.views.actionsheets.ActionSheetManager;
import io.agora.agoravoice.ui.views.actionsheets.BackgroundActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.GiftActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.HostPanelOperateActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.MusicActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.SoundEffectActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.ThreeDimenVoiceActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.ToolActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.UserListActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.VoiceBeautyActionSheet;
import io.agora.agoravoice.ui.views.bottombar.AbsBottomBar;
import io.agora.agoravoice.ui.views.bottombar.ChatRoomBottomBar;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.GiftUtil;
import io.agora.agoravoice.utils.RoomBgUtil;
import io.agora.agoravoice.utils.ToastUtil;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcChannel;

public class ChatRoomActivity extends AbsLiveActivity implements View.OnClickListener, RoomEventListener  {
    private static final String TAG = ChatRoomActivity.class.getSimpleName();

    private CropBackgroundRelativeLayout mBackground;

    // Room basic info
    private Const.Role mRole = Const.Role.audience;
    private int mBackgroundImageRes;
    private boolean mIsOwner;
    private boolean mIsHost;

    private ChatRoomBottomBar mBottomBar;
    private RtcStatsView mStatView;
    private RoomMessageList mMessageList;
    private MessageEditLayout mMessageEdit;
    private RoomUserActionView mUserAction;
    private ChatRoomHostPanel mHostPanel;

    private UserListActionSheet mUserListActionSheet;

    private AbsBottomBar.BottomBarListener mBottomBarListener = new AbsBottomBar.BottomBarListener() {
        @Override
        public void onTextEditClicked() {
            if (mMessageEdit != null && mMessageEdit.getVisibility() == View.GONE) {
                mMessageEdit.setVisibility(View.VISIBLE);
                mMessageEdit.setEditClicked();
                showInputMethodWithView(mMessageEdit.editText());
            }
        }

        @Override
        public void onButtonClicked(Const.Role role, View view, int index, boolean isActivated) {
            if (role == Const.Role.owner ||
                role == Const.Role.host) {
                switch (index) {
                    case 0:
                        ToolActionSheet toolActionSheet = (ToolActionSheet)
                            createActionSheet(ActionSheetManager.ActionSheet.tool);
                        toolActionSheet.setRole(mRole);
                        toolActionSheet.setToolActionListener(mToolActionListener);
                        toolActionSheet.setAppConfig(config());
                        showActionSheet(toolActionSheet, true);
                        break;
                    case 1:
                        SoundEffectActionSheet effectActionSheet = (SoundEffectActionSheet)
                                createActionSheet(ActionSheetManager.ActionSheet.sound_effect);
                        effectActionSheet.setSoundEffectActionListener(mSoundEffectListener);
                        effectActionSheet.setConfig(config());
                        showActionSheet(effectActionSheet, true);
                        break;
                    case 2:
                        VoiceBeautyActionSheet voiceBeautyActionSheet = (VoiceBeautyActionSheet)
                                createActionSheet(ActionSheetManager.ActionSheet.voice_beauty);
                        voiceBeautyActionSheet.setVoiceBeautyActionListener(mVoiceBeautyListener);
                        voiceBeautyActionSheet.setConfig(config());
                        showActionSheet(voiceBeautyActionSheet, true);
                        break;
                    case 3:
                        config().setAudioMuted(!isActivated);
                        proxy().getAudioManager().muteLocalAudio(roomId, !isActivated);
                        mHostPanel.updateMuteState(null, config().getAudioMuted(),
                                null, null, null);
                        break;
                }
            } else if (role == Const.Role.audience) {
                if (index == 0) {
                    ToolActionSheet toolActionSheet = (ToolActionSheet)
                            createActionSheet(ActionSheetManager.ActionSheet.tool);
                    toolActionSheet.setRole(mRole);
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

    private SoundEffectActionSheet.SoundEffectActionListener mSoundEffectListener
            = new SoundEffectActionSheet.SoundEffectActionListener() {
        @Override
        public void onVoiceBeautySelected(int type) {
            Log.i(TAG, "onVoiceBeautySelected:" + type);
            config().setAudioEffect(type);
            proxy().getAudioManager().enableAudioEffect(type);
        }

        @Override
        public void on3DHumanVoiceSelected() {
            Log.i(TAG, "on3DHumanVoiceSelected");
            ThreeDimenVoiceActionSheet voiceActionSheet =
                    (ThreeDimenVoiceActionSheet) createActionSheet(
                            ActionSheetManager.ActionSheet.three_dimen_voice);
            voiceActionSheet.setConfig(config());
            voiceActionSheet.setThreeDimenVoiceActionListener(mThreeDimenVoiceListener);
            voiceActionSheet.setup();
            showActionSheet(voiceActionSheet, false);
        }

        @Override
        public void onElectronicVoiceParamChanged(int key, int value) {
            Log.i(TAG, "onElectronicVoiceParamChanged " + key + "," + value);
            proxy().getAudioManager().setElectronicParams(key, value);
            config().setElectronicVoiceParam(key, value);
        }

        @Override
        public void onVoiceBeautyUnselected() {
            Log.i(TAG, "onVoiceBeautyUnselected");
            config().disableAudioEffect();
            proxy().getAudioManager().disableAudioEffect();
        }
    };

    private ThreeDimenVoiceActionSheet.ThreeDimenVoiceActionListener
        mThreeDimenVoiceListener = new ThreeDimenVoiceActionSheet.ThreeDimenVoiceActionListener() {
        @Override
        public void onThreeDimenVoiceEnabled(boolean enabled) {
            Log.i(TAG, "onThreeDimenVoiceEnabled:" + enabled);
            if (enabled) {
                proxy().getAudioManager().enableAudioEffect(AudioManager.EFFECT_SPACING_3D_VOICE);
                config().setAudioEffect(AudioManager.EFFECT_SPACING_3D_VOICE);
            } else {
                proxy().getAudioManager().disableAudioEffect();
                config().disableAudioEffect();
            }
        }

        @Override
        public void onThreeDimenVoiceSpeedChanged(int speed) {
            Log.i(TAG, "onThreeDimenVoiceSpeedChanged:" + speed);
            proxy().getAudioManager().set3DHumanVoiceParams(speed);
            config().set3DVoiceSpeed(speed);
        }

        @Override
        public void onThreeDimenVoiceActionClosed() {
            Log.i(TAG, "onThreeDimenVoiceActionClosed");
            closeActionSheet();
        }
    };

    private VoiceBeautyActionSheet.VoiceBeautyActionListener mVoiceBeautyListener
            = new VoiceBeautyActionSheet.VoiceBeautyActionListener() {
        @Override
        public void onVoiceBeautySelected(int type) {
            config().setAudioEffect(type);
            proxy().getAudioManager().enableAudioEffect(type);
        }

        @Override
        public void onVoiceBeautyUnselected() {
            config().disableAudioEffect();
            proxy().getAudioManager().disableAudioEffect();
        }
    };

    private GiftActionSheet.GiftActionListener mGiftActionListener = index -> {
        closeActionSheet();
        // For this moment, gifts can be sent one at a time,
        // so the count will always be 1
        proxy().sendGift(config().getUserToken(), roomId,
                GiftUtil.getGiftIdFromIndex(index), 1);
    };

    private BackgroundActionSheet.BackgroundActionSheetListener mBackgroundListener =
            new BackgroundActionSheet.BackgroundActionSheetListener() {
                @Override
                public void onBackgroundPicSelected(int index, int res) {
                    proxy().modifyRoom(config().getUserToken(),
                            roomId, RoomBgUtil.indexToString(index));
                    config().setBgImageSelected(index);
                }

                @Override
                public void onBackgroundBackClicked() {
                    closeActionSheet();
                }
            };

    private MusicActionSheet.MusicActionSheetListener mMusicListener =
            new MusicActionSheet.MusicActionSheetListener() {
                @Override
                public void onActionSheetMusicSelected(int index, String name, String url) {
                    proxy().getAudioManager().startBackgroundMusic(roomId, url);
                }

                @Override
                public void onVolumeChanged(int progress) {
                    config().setBgMusicVolume(progress);
                    proxy().getAudioManager().adjustBackgroundMusicVolume(progress);
                }

                @Override
                public void onActionSheetMusicStopped() {
                    proxy().getAudioManager().stopBackgroundMusic();
                }

                @Override
                public void onActionSheetClosed() {
                    closeActionSheet();
                }
            };

    private ToolActionSheet.ToolActionListener mToolActionListener = (role, view, index) -> {
        switch (role) {
            case owner:
                switch (index) {
                    case 0:
                        setInEarMonitoring(view);
                        break;
                    case 1:
                        MusicActionSheet musicActionSheet = (MusicActionSheet)
                                createActionSheet(ActionSheetManager.ActionSheet.music);
                        musicActionSheet.setMusicActionSheetListener(mMusicListener);
                        musicActionSheet.setCurrentMusicIndex(config().getCurMusicIndex());
                        musicActionSheet.setCurrentVolume(config().getBgMusicVolume());
                        showActionSheet(musicActionSheet, false);
                        break;
                    case 2:
                        BackgroundActionSheet backgroundActionSheet = (BackgroundActionSheet)
                                createActionSheet(ActionSheetManager.ActionSheet.background);
                        backgroundActionSheet.setSelected(config().getBgImageSelected());
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
                    case 0:
                        setInEarMonitoring(view);
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

    private void setInEarMonitoring(View view) {
        if (headSetWithMicPlugged()) {
            boolean wanted = !view.isActivated();
            proxy().getAudioManager().enableInEarMonitoring(wanted);
            config().setInEarMonitoring(wanted);
            view.setActivated(wanted);
        } else {
            ToastUtil.showShortToast(application(), R.string.toast_no_wired_mic_plugged);
        }
    }

    private void showStatsView() {
        if (mStatView != null) mStatView.show();
    }

    private MessageEditLayout.MessageEditListener mMessageEditListener = message -> {
        if (TextUtils.isEmpty(message)) {
            ToastUtil.showShortToast(ChatRoomActivity.this, R.string.send_empty_message);
        } else {
            proxy().sendChatMessage(config().getUserToken(),
                    getString(R.string.app_id), roomId, message);
        }

        hideInputMethodWithView(mMessageEdit.editText());
    };

    private UserListActionSheet.UserListActionSheetListener
            mUserListActionSheetListener = new UserListActionSheet.UserListActionSheetListener() {
        @Override
        public void onUserInvited(int no, String userId, String userName) {
            closeActionSheet();
            if (mHostPanel.hasUserTakenASeat(userId)) {
                ToastUtil.showShortToast(ChatRoomActivity.this, R.string.toast_user_has_taken_seat);
                return;
            }

            String format = getResources().getString(R.string.dialog_invite_user_message);
            String message = String.format(format, userName);
            curDialog = showDialog(getString(R.string.dialog_invite_user_title), message,
                    getString(R.string.text_yes), getString(R.string.text_no),
                    () -> {
                        dismissDialog();
                        int ret = requestSeatBehavior(no, SeatBehavior.INVITE, userId, userName);
                        // Here only handles errors that related to
                        // local implementation but not those returned
                        // from the server.
                        if (ret == Const.ERR_REPEAT_INVITE) {
                            Log.i("ChatRoom", "repeat invitation exception");
                            String f = getResources().getString(R.string.toast_repeat_invite);
                            String toast = String.format(f, userName);
                            ToastUtil.showShortToast(ChatRoomActivity.this, toast);
                        }
                    }, () -> dismissDialog());
        }

        @Override
        public void onApplicationAccepted(int no, String userId, String userName) {
            String title = getResources().getString(R.string.dialog_apply_seat_title);
            String message = getResources().getString(R.string.dialog_application_accepted_message);
            message = String.format(Locale.getDefault(), message, userName);
            curDialog = showDialog(title, message,
                    getResources().getString(R.string.text_accept),
                    getResources().getString(R.string.text_cancel),
                    () -> {
                        dismissDialog();
                        requestSeatBehavior(no, SeatBehavior.APPLY_ACCEPT, userId, userName);
                    },
                    () -> dismissDialog());
        }

        @Override
        public void onApplicationRejected(int no, String userId, String userName) {
            String title = getResources().getString(R.string.dialog_apply_seat_title);
            String message = getResources().getString(R.string.dialog_application_rejected_message);
            message = String.format(Locale.getDefault(), message, userName);
            curDialog = showDialog(title, message,
                    getResources().getString(R.string.text_accept),
                    getResources().getString(R.string.text_cancel),
                    () -> {
                        dismissDialog();
                        requestSeatBehavior(no, SeatBehavior.APPLY_REJECT, userId, userName);
                    }, () -> dismissDialog());
        }
    };

    private RoomUserActionView.RoomUserActionViewListener
            mRoomUserActionViewListener = view -> {
        setupUserListActionSheet(false, -1,
                mUserAction.notificationShown());
        // If there are new applications, remove the
        // notification because the user action sheet will
        // display the application first.
        mUserAction.showNotification(false);
    };

    private void setupUserListActionSheet(boolean invite, int seatNo, boolean showApplication) {
        mUserListActionSheet = (UserListActionSheet)
                createActionSheet(ActionSheetManager.ActionSheet.user);
        mUserListActionSheet.setOwner(mIsOwner, ownerId);
        mUserListActionSheet.setInvitationManager(proxy().getRoomInvitationManager(roomId));
        mUserListActionSheet.setUserActionSheetListener(mUserListActionSheetListener);
        mUserListActionSheet.showInviteStatus(invite);
        mUserListActionSheet.updateUserList(mHostPanel.getAllUsers());
        mUserListActionSheet.setSeatNo(seatNo);
        mUserListActionSheet.showApplication(showApplication);
        showActionSheet(mUserListActionSheet, true);
    }

    private HostPanelOperateActionSheet.HostPanelActionSheetListener
            mHostPanelActionListener = new HostPanelOperateActionSheet.HostPanelActionSheetListener() {
        @Override
        public void onSeatUnblock(int position) {
            closeActionSheet();
            curDialog = showDialog(R.string.dialog_unlock_seat_title,
                    R.string.dialog_unlock_seat_message,
                    R.string.text_confirm,
                    R.string.text_cancel,
                    () -> {
                        dismissDialog();
                        changeState(ChatRoomHostPanel.Seat.STATE_OPEN, position + 1);
                    }, () -> dismissDialog());
        }

        @Override
        public void onSeatBlocked(int position) {
            closeActionSheet();
            curDialog = showDialog(R.string.dialog_lock_seat_title,
                    R.string.dialog_lock_seat_message,
                    R.string.text_confirm,
                    R.string.text_cancel,
                    () -> {
                        dismissDialog();
                        ChatRoomHostPanel.Seat seat = mHostPanel.getSeat(position);
                        if (seat.getState() == ChatRoomHostPanel.Seat.STATE_TAKEN &&
                                seat.getUser() != null) {
                            ChatRoomHostPanel.SeatUser user = seat.getUser();
                            proxy().getAudioManager().enableRemoteAudio(
                                    roomId, user.getUserId(), false);
                        }

                        changeState(ChatRoomHostPanel.Seat.STATE_BLOCK, position + 1);
                    }, () -> dismissDialog());
        }

        private void changeState(int state, int no) {
            switch (state) {
                case ChatRoomHostPanel.Seat.STATE_BLOCK:
                    proxy().changeSeatState(config().getUserToken(),
                            roomId, no, ChatRoomHostPanel.Seat.STATE_BLOCK);
                    break;
                case ChatRoomHostPanel.Seat.STATE_OPEN:
                    proxy().changeSeatState(config().getUserToken(),
                            roomId, no, ChatRoomHostPanel.Seat.STATE_OPEN);
                    break;
            }
        }

        @Override
        public void onSeatInvited(int position) {
            closeActionSheet();
            mUserAction.showNotification(false);
            // Seat no starts from 1, while position starts from 0
            setupUserListActionSheet(true, position + 1,
                    mUserAction.notificationShown());

            // Not showing tabs here, does not need application
            // tab at this moment
            mUserListActionSheet.showTab(false);
        }

        @Override
        public void onSeatApplied(int position) {
            closeActionSheet();
            curDialog = showDialog(R.string.dialog_apply_seat_title,
                    R.string.dialog_apply_seat_message,
                    R.string.text_confirm,
                    R.string.text_cancel,
                    () -> {
                        requestSeatBehavior(position + 1,
                                SeatBehavior.APPLY,
                                ownerId, ownerName);
                        dismissDialog();
                    },
                    () -> dismissDialog());
        }

        @Override
        public void onSeatMuted(int position, String userId, String userName, boolean muted) {
            closeActionSheet();
            if (mIsHost && config().getUserId().equals(userId)) {
                config().setAudioMuted(muted);
                proxy().getAudioManager().muteLocalAudio(roomId, muted);
                mHostPanel.updateMuteState(null, config().getAudioMuted(),
                        null, null, null);
                mBottomBar.setEnableAudio(!config().getAudioMuted());
            } else if (mIsOwner) {
                String title = muted ? getString(R.string.dialog_mute_title)
                        : getString(R.string.dialog_unmute_title);
                String format = muted ? getString(R.string.dialog_mute_message)
                        : getString(R.string.dialog_unmute_message);
                String message = String.format(format, userName);
                curDialog = showDialog(title, message,
                        getString(R.string.text_confirm),
                        getString(R.string.text_cancel),
                        () -> {
                            config().setAudioMuted(muted);
                            proxy().getAudioManager().muteRemoteAudio(roomId,
                                    mHostPanel.getStreamInfo(position), muted);
                            dismissDialog();
                        }, () -> dismissDialog());
            }
        }

        @Override
        public void onUserLeave(int position, String userId, String userName) {
            closeActionSheet();

            boolean isHostLeave = mIsHost && config().getUserId().equals(userId);
            if (!isHostLeave && !mIsOwner) return;

            String title = getResources().getString(R.string.dialog_leave_seat_title);
            final String message;
            if (mIsOwner) {
                String format = getResources().getString(R.string.dialog_leave_seat_message_owner);
                message = String.format(format, userName);
            } else if (mIsHost && config().getUserId().equals(userId)) {
                message = getResources().getString(R.string.dialog_leave_seat_message_host);
            } else message = "";

            runOnUiThread(() -> {
                closeActionSheet();
                // Only owner and host can trigger user leave.
                int behavior = mIsOwner ? SeatBehavior.FORCE_LEAVE : SeatBehavior.LEAVE;
                curDialog = showDialog(title, message,
                        getResources().getString(R.string.text_confirm),
                        getResources().getString(R.string.text_cancel),
                        () -> {
                            dismissDialog();
                            requestSeatBehavior(position + 1,
                                    behavior, userId, userName);
                        },
                        () -> dismissDialog());
            });
        }
    };

    private ChatRoomHostPanel.ChatRoomHostPanelListener
            mHostPanelListener = new ChatRoomHostPanel.ChatRoomHostPanelListener() {
        @Override
        public void onSeatClicked(int position, @Nullable ChatRoomHostPanel.Seat seat) {
            HostPanelOperateActionSheet operateActionSheet =
                    (HostPanelOperateActionSheet) createActionSheet(
                            ActionSheetManager.ActionSheet.seat_op);
            operateActionSheet.setOperationListener(mHostPanelActionListener);
            operateActionSheet.setSeatPosition(position);
            operateActionSheet.setSeat(seat);
            operateActionSheet.setMyRole(mIsOwner, mIsHost);
            operateActionSheet.setSeatState(seat == null ?
                    ChatRoomHostPanel.Seat.STATE_OPEN : seat.getState());
            operateActionSheet.notifyChange();
            showActionSheet(operateActionSheet, true);
        }

        @Override
        public void onSeatUserRemoved(int position, String userId, String userName) {
            if (config().getUserId().equals(userId) && mIsHost) {
                mIsHost = false;
                mBottomBar.setRole(Const.Role.audience);
                mHostPanel.setMyInfo(Const.Role.audience, config().getUserId());

                // Because the owner doesn't give me a
                // message when he makes me leave the seat,
                // so the only time I can know this is when
                // I've checked that I have left the seat.
                proxy().getAudioManager().disableLocalAudio(roomId);
            }
        }

        @Override
        public void onSeatUserTaken(int position, String userId, String userName) {
            if (config().getUserId().equals(userId) && !mIsHost) {
                mIsHost = true;
                mBottomBar.setRole(Const.Role.host);
                mHostPanel.setMyInfo(Const.Role.host, config().getUserId());
                mHostPanel.setStreamInfo(userId,
                        createFakeStreamInfoForMyself(!config().getAudioMuted()));
            }
        }

        private RoomStreamInfo createFakeStreamInfoForMyself(boolean enableAudio) {
            // Because only remote media streams will invoke the
            // callback functions and obtain their streams,
            // we must create a fake stream info for my seat
            // to record the mute status of mine.
            RoomStreamInfo info = new RoomStreamInfo();
            info.enableAudio(enableAudio);
            return info;
        }
    };

    // Callbacks to tell that the seat requests have been sent
    // to the other users by client.
    // The other users' responds will be received in another callback.
    private ProxyManager.SeatListener mSeatListener = new ProxyManager.SeatListener() {
        @Override
        public void onSeatBehaviorSuccess(int type, String userId, String userName, int no) {
            runOnUiThread(() -> handleSeatBehaviorSuccess(type, userId, userName, no));
        }

        private void handleSeatBehaviorSuccess(int type, String userId, String userName, int no) {
            switch (type) {
                case SeatBehavior.INVITE:
                    String inviteFormat = getResources().getString(R.string.toast_invite_success);
                    String inviteToast = String.format(inviteFormat, userName);
                    ToastUtil.showShortToast(ChatRoomActivity.this, inviteToast);
                    break;
                case SeatBehavior.APPLY:
                    ToastUtil.showShortToast(application(), R.string.toast_application_sent);
                    break;
                case SeatBehavior.INVITE_ACCEPT:
                case SeatBehavior.INVITE_REJECT:
                    break;
                case SeatBehavior.APPLY_ACCEPT:
                    // I have successfully accept the application of
                    // an audience, and now I must let the user to
                    // send audio streams
                    proxy().getAudioManager().enableRemoteAudio(roomId, userId, true);
                    proxy().getRoomInvitationManager(roomId)
                            .receiveSeatBehaviorResponse(userId, userName, no, type);
                    updateUserListActionSheetIfShown();
                    break;
                case SeatBehavior.APPLY_REJECT:
                    proxy().getRoomInvitationManager(roomId)
                            .receiveSeatBehaviorResponse(userId, userName, no, type);
                    updateUserListActionSheetIfShown();
                    break;
                case SeatBehavior.FORCE_LEAVE:
                    proxy().getAudioManager().enableRemoteAudio(roomId, userId, false);
                    break;
                case SeatBehavior.LEAVE:
                    proxy().getAudioManager().disableLocalAudio(roomId);
                    break;
                default: break;
            }
        }

        @Override
        public void onSeatBehaviorFail(int type, String userId, String userName, int no, int code, String msg) {
            runOnUiThread(() -> handleSeatBehaviorFail(type, userId, userName, no, code, msg));
        }

        private void handleSeatBehaviorFail(int type, String userId, String userName, int no, int code, String msg) {
            switch (type) {
                case SeatBehavior.INVITE:
                    String inviteFormat = getResources().getString(R.string.toast_invite_fail);
                    String inviteHint = String.format(inviteFormat, code);
                    ToastUtil.showShortToast(ChatRoomActivity.this, inviteHint);
                    proxy().getRoomInvitationManager(roomId).
                            handleSeatBehaviorRequestFail(userId, userName, no, type, code);
                    break;
                case SeatBehavior.APPLY:
                    ToastUtil.showShortToast(application(), R.string.toast_application_sent_fail);
                    break;
                case SeatBehavior.INVITE_ACCEPT:
                case SeatBehavior.APPLY_ACCEPT:
                    if (code == ErrorCode.ERROR_SEAT_TAKEN) {
                        proxy().getRoomInvitationManager(roomId)
                                .handleSeatBehaviorRequestFail(userId, userName, no, type, code);
                        updateUserListActionSheetIfShown();
                        ToastUtil.showShortToast(ChatRoomActivity.this,
                                ErrorCode.getErrorMessageRes(code));
                    }
                    break;
                case SeatBehavior.INVITE_REJECT:
                case SeatBehavior.APPLY_REJECT:
                case SeatBehavior.FORCE_LEAVE:
                case SeatBehavior.LEAVE:
                    String format = getResources().getString(R.string.toast_request_fail_message);
                    String message = String.format(format, msg, code);
                    format = getResources().getString(R.string.toast_request_fail_message);
                    message = String.format(format, msg, code);
                    ToastUtil.showShortToast(ChatRoomActivity.this, message);
                default:
            }
        }

        @Override
        public void onSeatStateChanged(int no, int state) {

        }

        @Override
        public void onSeatStateChangeFail(int no, int state, int code, String message) {

        }
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat_room);
        getIntentInfo(getIntent());
        checkPermissions();
    }

    @Override
    public void onAllPermissionsGranted() {
        initView();
        enterRoom();
        initSeatManager();
    }

    private void getIntentInfo(Intent intent) {
        roomId = intent.getStringExtra(Const.KEY_ROOM_ID);
        roomName = intent.getStringExtra(Const.KEY_ROOM_NAME);
        int role = intent.getIntExtra(Const.KEY_USER_ROLE, -1);
        mRole = Const.Role.getRole(role);
        ownerId = intent.getStringExtra(Const.KEY_USER_ID);
        ownerName = intent.getStringExtra(Const.KEY_USER_NAME);
        mIsOwner = config().getUserId().equals(ownerId);
        String bgIndex = intent.getStringExtra(Const.KEY_BACKGROUND);
        mBackgroundImageRes = RoomBgUtil.getRoomBgPicRes(RoomBgUtil.idToIndex(bgIndex));
    }

    private void initView() {
        detectKeyboard();

        mBackground = findViewById(R.id.chat_room_background_layout);
        initBackground();

        mBottomBar = findViewById(R.id.chat_room_bottom_bar);
        mBottomBar.setBottomBarListener(mBottomBarListener);
        mBottomBar.setRole(mRole);

        mStatView = findViewById(R.id.rtc_stats_view);
        mStatView.setCloseListener(this);

        mMessageList = findViewById(R.id.chat_room_message_list);
        mMessageEdit = findViewById(R.id.message_edit_text);
        mMessageEdit.setMessageEditListener(mMessageEditListener);

        mUserAction = findViewById(R.id.chat_room_user_action);
        mUserAction.setRoomUserActionListener(mRoomUserActionViewListener);

        // The owner info is received from room initialization callback
        mHostPanel = findViewById(R.id.chat_room_host_panel);
        mHostPanel.setPanelListener(mHostPanelListener);
        mHostPanel.setMyInfo(mRole, config().getUserId());
        mHostPanel.setOwnerName(ownerName);
        mHostPanel.setOwnerUid(ownerId);
        mHostPanel.setOwnerImage(ownerId);

        findViewById(R.id.chat_room_exit_btn).setOnClickListener(this);
    }

    private void initBackground() {
        mBackground.setCropBackground(mBackgroundImageRes);
    }

    private void enterRoom() {
        proxy().enterRoom(roomId, roomName, config().getUserId(),
                config().getNickname(), mRole, this);
    }

    private void initSeatManager() {
        proxy().createSeatManager(roomId);
        proxy().addSeatListener(mSeatListener);
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
    protected void onInputMethodToggle(boolean shown, int height) {
        RelativeLayout.LayoutParams params =
                (RelativeLayout.LayoutParams) mMessageEdit.getLayoutParams();

        params.bottomMargin = height;
        mMessageEdit.setLayoutParams(params);
        if (shown) {
            mMessageEdit.setEditClicked();
        } else {
            mMessageEdit.setVisibility(View.GONE);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.chat_room_exit_btn:
                onBackPressed();
                break;
            case R.id.stats_close_btn:
                closeStatsView();
                break;
        }
    }

    private void closeStatsView() {
        if (mStatView != null) mStatView.dismiss();
    }

    @Override
    public void onJoinSuccess(String roomId, String roomName) {
        runOnUiThread(() -> ToastUtil.showShortToast(application(), R.string.toast_join_class_success));
    }

    @Override
    public void onJoinFail(int code, String reason) {
        runOnUiThread(() -> {
            int msgRes = code == ErrorCode.ERROR_ROOM_MAX_USER
                    ? R.string.error_room_max_user
                    : R.string.toast_join_class_fail;
            ToastUtil.showShortToast(application(), msgRes);
            onRoomFinish(false);
        });
    }

    @Override
    public void onRoomLeaved() {
        if (mIsHost) {
            ChatRoomHostPanel.Seat seat = mHostPanel.getSeatByUser(config().getUserId());
            requestSeatBehavior(seat.getPosition() + 1, SeatBehavior.LEAVE,
                    config().getUserId(), config().getNickname());
        }
        removeSeatManager();
        if (mIsOwner) proxy().destroyRoom(config().getUserToken(), roomId);
    }

    private void updateRoomUserList(List<RoomUserInfo> userList, List<RoomUserInfo> leftList) {
        InvitationManager manager = proxy().getRoomInvitationManager(roomId);
        if (manager != null) {
            manager.updateUserList(userList);
        }

        if (leftList != null && leftList.size() > 0) {
            for (RoomUserInfo info : leftList) {
                proxy().getRoomInvitationManager(roomId).userLeft(info.userId);
            }
        }

        updateUserListActionSheetIfShown();
    }

    private void updateUserListActionSheetIfShown() {
        if (mUserListActionSheet != null &&
                mUserListActionSheet.isShown()) {
            mUserListActionSheet.updateUserList(mHostPanel.getAllUsers());
        }
    }

    @Override
    public void onRoomMembersInitialized(@Nullable RoomUserInfo teacher, int count,
                                         List<RoomUserInfo> userList, List<RoomStreamInfo> streamInfo) {
        runOnUiThread(() -> {
            mUserAction.resetCount(count);
            mMessageList.addJoinMessage(config().getNickname());
            updateRoomUserList(userList, null);

            // Note: this is must be called before handling the
            // seat user's audio/video capture, because host panel
            // is used to manage the streams
            updateHostPanel(teacher, streamInfo);

            if (teacher != null) {
                if (teacher.userId.equals(config().getUserId())) {
                    // I am the owner, and I enter this room after
                    // accidentally leaving this room within one minute ago.
                    mIsOwner = true;
                    mBottomBar.setRole(Const.Role.owner);
                } else {
                    // If I am not the owner, I should handle the stream of
                    // myself.
                    RoomStreamInfo myStreamInfo = null;
                    for (RoomStreamInfo info : streamInfo) {
                        if (info.userId.equals(config().getUserId())) {
                            myStreamInfo = info;
                        }
                    }

                    if (myStreamInfo != null) {
                        XLog.d("onRoomMembersInitialized audio " + myStreamInfo.enableAudio);
                        proxy().getAudioManager().enableLocalAudio(roomId, myStreamInfo.enableAudio);
                    }
                }
            }
        });
    }

    private boolean teacherEnablesAudio(@Nullable RoomUserInfo teacher, List<RoomStreamInfo> streamInfo) {
        if (teacher == null) return false;

        String teacherId = teacher.userId;
        if (teacherId == null) return false;

        for (RoomStreamInfo info : streamInfo) {
            if (teacherId.equals(info.userId)) {
                return info.enableAudio;
            }
        }

        return false;
    }

    private void updateHostPanel(RoomUserInfo teacher, List<RoomStreamInfo> streamInfo) {
        if (teacher != null) {
            ownerId = teacher.userId;
            ownerName = teacher.userName;
            mHostPanel.setOwnerName(ownerName);
            mHostPanel.setOwnerUid(ownerId);
            mHostPanel.setOwnerImage(ownerId);
            mHostPanel.setOwnerMuted(!teacherEnablesAudio(teacher, streamInfo));
        }

        RoomStreamInfo myStreamInfo = null;
        for (RoomStreamInfo info : streamInfo) {
            if (info.userId != null && info.userId.equals(config().getUserId())) {
                myStreamInfo = info;
            }
        }

        Map<String, RoomStreamInfo> streamMap = new HashMap<>();
        for (RoomStreamInfo info : streamInfo) {
            streamMap.put(info.userId, info);
        }

        mHostPanel.updateMuteState(myStreamInfo,
                myStreamInfo == null || !myStreamInfo.enableAudio,
                null, streamMap, null);
    }

    @Override
    public void onRoomMembersJoined(int total, List<RoomUserInfo> totalList,
                                    int joinCount, List<RoomUserInfo> joinedList) {
        runOnUiThread(() -> {
            if (mUserAction != null) mUserAction.resetCount(total);
            addJoinMessage(joinedList);
            updateRoomUserList(totalList, null);
        });
    }

    private void addJoinMessage(List<RoomUserInfo> list) {
        for (RoomUserInfo info : list) {
            mMessageList.addJoinMessage(info.userName);
        }
    }

    @Override
    public void onRoomMembersLeft(int total, List<RoomUserInfo> totalList,
                                  int leftCount, List<RoomUserInfo> leftList) {
        runOnUiThread(() -> {
            if (mUserAction != null) mUserAction.resetCount(total);
            addLeaveMessage(leftList);
            updateRoomUserList(totalList, leftList);
        });
    }

    private void addLeaveMessage(List<RoomUserInfo> list) {
        for (RoomUserInfo info : list) {
            mMessageList.addLeaveMessage(info.userName);
        }
    }

    @Override
    public void onRoomMembersUpdated(int count, List<RoomUserInfo> updatedList) {

    }

    @Override
    public void onChatMessageReceive(String fromUserId, String fromUserName, String message) {
        runOnUiThread(() -> mMessageList.addChatMessage(fromUserName, message));
    }

    @Override
    public void onStreamInitialized(RoomStreamInfo myStreamInfo, List<RoomStreamInfo> streamList) {
        runOnUiThread(() -> {
            updateSeatStates(myStreamInfo, streamList, null, null);
            // My stream state also determines whether I should
            // start capture media streams.
            if (myStreamInfo != null && myStreamInfo.enableAudio) {
                XLog.d("onStreamInitialized mystream audio enabled");
                proxy().getAudioManager().enableLocalAudio(roomId, true);
            }
        });
    }

    @Override
    public void onStreamAdded(RoomStreamInfo myStreamInfo, List<RoomStreamInfo> addList) {
        runOnUiThread(() -> updateSeatStates(myStreamInfo, null, addList, null));
    }

    @Override
    public void onStreamUpdated(RoomStreamInfo myStreamInfo, List<RoomStreamInfo> updatedList) {
        runOnUiThread(() -> updateSeatStates(myStreamInfo, updatedList, null, null));
    }

    @Override
    public void onStreamRemoved(RoomStreamInfo myStreamInfo, List<RoomStreamInfo> removeList) {
        runOnUiThread(() -> updateSeatStates(myStreamInfo, null, null, removeList));
    }

    private void updateSeatStates(RoomStreamInfo myStreamInfo,
                                  List<RoomStreamInfo> updateList,
                                  List<RoomStreamInfo> addedList,
                                  List<RoomStreamInfo> removedList) {
        Map<String, RoomStreamInfo> updateMap = new HashMap<>();
        if (updateList != null) {
            for (RoomStreamInfo info : updateList) {
                updateMap.put(info.userId, info);
            }
        }

        Map<String, RoomStreamInfo> addedMap = new HashMap<>();
        if (addedList != null) {
            for (RoomStreamInfo info : addedList) {
                addedMap.put(info.userId, info);
            }
        }

        Map<String, RoomStreamInfo> removedMap = new HashMap<>();
        if (removedList != null) {
            for (RoomStreamInfo info : removedList) {
                removedMap.put(info.userId, info);
            }
        }

        mHostPanel.updateMuteState(myStreamInfo,
                myStreamInfo != null ? !myStreamInfo.enableAudio : config().getAudioMuted(),
                updateMap, addedMap, removedMap);

        if (myStreamInfo != null) {
            mBottomBar.setEnableAudio(myStreamInfo.enableAudio);
        }
    }

    @Override
    public void onRoomPropertyUpdated(@NonNull String backgroundId, @Nullable List<SeatStateData> seats,
                                      @Nullable List<GiftSendInfo> giftRank, @Nullable GiftSendInfo giftSent) {
        int idx = RoomBgUtil.idToIndex(backgroundId);
        int resource = RoomBgUtil.getRoomBgPicRes(idx);
        Log.i(TAG, "onRoomPropertyUpdated background set " + backgroundId + " " + idx + " " + resource);

        runOnUiThread(() -> {
            mHostPanel.updateSeatStates(seats);

            if (giftRank != null && giftRank.size() > 0) {
                ArrayList<String> rankIds = new ArrayList<>();
                for (GiftSendInfo info : giftRank) {
                    rankIds.add(info.userId);
                }
                mUserAction.setUserIcons(rankIds);
            }

            if (giftSent != null) {
                int index = GiftUtil.parseGiftIndexFromId(giftSent.giftId);
                GiftUtil.showGiftAnimation(this, index);
                mMessageList.addGiftSendMessage(giftSent.userName, index);
            }

            if (!TextUtils.isEmpty(backgroundId)) {
                int index = RoomBgUtil.idToIndex(backgroundId);
                int res = RoomBgUtil.getRoomBgPicRes(index);
                if (res > 0) mBackground.setCropBackground(res);
            }
        });
    }

    @Override
    public void onReceiveSeatBehavior(@NonNull String roomId, String fromUserId,
                                      String fromUserName, int no, int behavior) {
        switch (behavior) {
            case SeatBehavior.INVITE:
                String title = getString(R.string.dialog_invite_user_title);
                String msgFormat = getString(R.string.dialog_receive_invite_message);
                String message = String.format(msgFormat, fromUserName);
                runOnUiThread(() -> curDialog = showDialog(title, message,
                    getResources().getString(R.string.text_accept),
                    getResources().getString(R.string.text_reject),
                    () -> {
                        requestSeatBehavior(no, SeatBehavior.INVITE_ACCEPT, fromUserId, fromUserName);
                        dismissDialog();
                    },
                    () -> {
                        requestSeatBehavior(no, SeatBehavior.INVITE_REJECT, fromUserId, fromUserName);
                        dismissDialog();
                    })
                );
                break;
            case SeatBehavior.APPLY:
                proxy().getRoomInvitationManager(roomId).receiveSeatBehaviorResponse(
                        fromUserId, fromUserName, no, behavior);

                runOnUiThread(() -> {
                    if (mUserListActionSheet != null && mUserListActionSheet.isShown()) {
                        mUserListActionSheet.updateUserList(mHostPanel.getAllUsers());
                        mUserListActionSheet.showApplication(true);
                    } else {
                        mUserAction.showNotification(true);
                    }
                });
                break;
            case SeatBehavior.INVITE_ACCEPT:
                runOnUiThread(() -> showToast(R.string.toast_invite_accepted, fromUserName));
                proxy().getAudioManager().enableRemoteAudio(roomId, fromUserId, true);
                proxy().getRoomInvitationManager(roomId).receiveSeatBehaviorResponse(
                        fromUserId, fromUserName, no, behavior);
                break;
            case SeatBehavior.INVITE_REJECT:
                runOnUiThread(() -> showToast(R.string.toast_invite_rejected, fromUserName));
                proxy().getRoomInvitationManager(roomId).receiveSeatBehaviorResponse(
                        fromUserId, fromUserName, no, behavior);
                break;
            case SeatBehavior.APPLY_ACCEPT:
                runOnUiThread(() -> showToast(R.string.toast_apply_accepted, fromUserName));
                proxy().getAudioManager().enableLocalAudio(roomId, true);
                break;
            case SeatBehavior.APPLY_REJECT:
                runOnUiThread(() -> showToast(R.string.toast_apply_rejected, fromUserName));
                break;
        }
    }

    @Override
    public void onRtcStats(@Nullable RtcChannel channel, @Nullable IRtcEngineEventHandler.RtcStats stats) {
        runOnUiThread(() -> {
            if (stats != null && mStatView.isShown()) {
                mStatView.setLocalStats(
                        stats.rxAudioKBitRate,
                        stats.rxPacketLossRate,
                        stats.txAudioKBitRate,
                        stats.txPacketLossRate,
                        stats.lastmileDelay);
            }
        });
    }

    private int requestSeatBehavior(int no, int type, String userId, String userName) {
        return proxy().requestSeatBehavior(config().getUserToken(),
                roomId, userId, userName, no, type);
    }

    private void showToast(int formatRes, String name) {
        String format = getResources().getString(formatRes);
        String message = String.format(format, name);
        ToastUtil.showShortToast(ChatRoomActivity.this, message);
    }

    @Override
    public void onRoomEnd() {
        runOnUiThread(() -> {
            onRoomFinish(true);
            ToastUtil.showShortToast(application(), R.string.toast_room_ends);
        });
    }

    @Override
    public void onBackPressed() {
        int titleRes = mIsOwner
                ? R.string.dialog_owner_end_live_title
                : R.string.dialog_leave_room_title;
        int msgRes = mIsOwner
                ? R.string.dialog_owner_end_live_message
                : R.string.dialog_leave_room_message;
        curDialog = showDialog(titleRes, msgRes,
            R.string.text_confirm,
            R.string.text_cancel,
            () -> onRoomFinish(true),
            this::dismissDialog);
    }

    private void onRoomFinish(boolean needLeave) {
        config().setCurMusicIndex(-1);
        dismissDialog();
        closeActionSheet();
        config().setInEarMonitoring(false);
        config().disableAudioEffect();
        config().setAudioMuted(false);
        config().setBgImageSelected(-1);

        if (needLeave) {
            proxy().leaveRoom(config().getUserToken(), roomId);
        }
        finish();
    }

    private void removeSeatManager() {
        proxy().removeSeatListener(mSeatListener);
        proxy().removeSeatManager(roomId);
    }

    @Override
    public void onResume() {
        super.onResume();
        detectNetworkState();
    }

    @Override
    public void onPause() {
        super.onPause();
        stopDetectNetworkState();
    }
}
