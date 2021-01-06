package io.agora.agoravoice.ui.activities;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.appcompat.widget.AppCompatEditText;
import androidx.appcompat.widget.AppCompatTextView;

import java.util.List;

import io.agora.agoravoice.R;
import io.agora.agoravoice.business.definition.struct.BusinessType;
import io.agora.agoravoice.business.server.retrofit.model.responses.RoomListResp;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.ui.views.CropBackgroundRelativeLayout;
import io.agora.agoravoice.ui.views.actionsheets.BackgroundActionSheet;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.RandomUtil;
import io.agora.agoravoice.utils.RoomBgUtil;
import io.agora.agoravoice.utils.ToastUtil;

public class PrepareActivity extends AbsLiveActivity {
    private static final int POLICY_MAX_DURATION = 10000;
    private static final int MAX_NAME_LENGTH = 25;

    private CropBackgroundRelativeLayout mBackgroundLayout;
    private int mBackgroundSelected;
    private AppCompatEditText mNameEdit;
    private AppCompatTextView mGoLiveBtn;

    private Handler mHandler;
    private final Runnable mRemovePolicyRunnable = this::closePolicyNotification;

    private final ProxyManager.RoomServiceListener mRoomListener = new ProxyManager.RoomServiceListener() {
        @Override
        public void onRoomCreated(String roomId, String roomName) {
            Intent intent = new Intent(PrepareActivity.this, ChatRoomActivity.class);
            intent.putExtra(Const.KEY_BACKGROUND, String.valueOf(mBackgroundSelected));
            intent.putExtra(Const.KEY_ROOM_NAME, roomName);
            intent.putExtra(Const.KEY_ROOM_ID, roomId);
            intent.putExtra(Const.KEY_USER_NAME, config().getNickname());
            intent.putExtra(Const.KEY_USER_ROLE, Const.Role.owner.ordinal());
            intent.putExtra(Const.KEY_USER_ID, config().getUserId());
            intent.putExtras(getIntent());
            startActivity(intent);

            finish();
        }

        @Override
        public void onGetRoomList(String nextId, int total, List<RoomListResp.RoomListItem> list) {
            // nothing needs to be done here
        }

        @Override
        public void onLeaveRoom() {
            // nothing needs to be done here
        }

        @Override
        public void onRoomServiceFailed(int type, int code, String msg) {
            if (type == BusinessType.CREATE_ROOM) {
                Log.i("Prepare", "create room fail:" + code + " " + msg);
                runOnUiThread(() -> mGoLiveBtn.setEnabled(true));
            }
        }
    };

    @Override
    protected void onHeadsetWithMicPlugged(boolean plugged) {
        // nothing needs to be done here
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_prepare);

        init();
        postPolicyCloseDelayed();
    }

    private void init() {
        mBackgroundLayout = findViewById(R.id.activity_prepare_background);
        setBackgroundPicture();

        mNameEdit = findViewById(R.id.room_name_edit);
        setRandomRoomName();
        mNameEdit.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.length() > MAX_NAME_LENGTH) {
                    String format = getString(R.string.room_name_too_long_toast_format);
                    String message = String.format(format, MAX_NAME_LENGTH);
                    ToastUtil.showShortToast(PrepareActivity.this, message);
                    mNameEdit.setText(s.subSequence(0, MAX_NAME_LENGTH));
                    mNameEdit.setSelection(MAX_NAME_LENGTH);
                }
            }
        });

        mGoLiveBtn = findViewById(R.id.prepare_go_live);
    }

    private void setBackgroundPicture() {
        if (mBackgroundLayout != null) {
            mBackgroundLayout.setCropBackground(RoomBgUtil.getRoomBgPicRes(mBackgroundSelected));
        }
    }

    private void setRandomRoomName() {
        mNameEdit.setText(RandomUtil.randomLiveRoomName(this));
    }

    private void postPolicyCloseDelayed() {
        mHandler = new Handler(getMainLooper());
        mHandler.postDelayed(mRemovePolicyRunnable, POLICY_MAX_DURATION);
    }

    private void removePolicyCloseRunnable() {
        if (mHandler != null) mHandler.removeCallbacks(mRemovePolicyRunnable);
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        RelativeLayout layout = findViewById(R.id.prepare_top_btn_layout);
        RelativeLayout.LayoutParams params =
                (RelativeLayout.LayoutParams) layout.getLayoutParams();
        params.topMargin += systemBarHeight;
        layout.setLayoutParams(params);
    }

    public void onViewClick(View view) {
        switch (view.getId()) {
            case R.id.prepare_close:
                onBackPressed();
                break;
            case R.id.prepare_choose_background:
                showBackgroundActionSheet();
                break;
            case R.id.prepare_random:
                setRandomRoomName();
                break;
            case R.id.prepare_go_live:
                checkRoomNameAndGoLive();
                break;
            case R.id.prepare_policy_close:
                closePolicyNotification();
                break;
        }
    }

    private void showBackgroundActionSheet() {
        BackgroundActionSheet bgActionSheet = new BackgroundActionSheet(this);
        bgActionSheet.setShowBackButton(false);
        showActionSheet(bgActionSheet, true);
        bgActionSheet.setOnBackgroundActionListener(new BackgroundActionSheet.BackgroundActionSheetListener() {
            @Override
            public void onBackgroundPicSelected(int index, int res) {
                mBackgroundSelected = index;
                setBackgroundPicture();
            }

            @Override
            public void onBackgroundBackClicked() {
                // Do not need to respond to this event for this activity
            }
        });
    }

    private void checkRoomNameAndGoLive() {
        if (!isRoomNameValid()) {
            ToastUtil.showShortToast(this, R.string.no_room_name_toast);
            return;
        }

        mGoLiveBtn.setEnabled(false);
        proxy().addRoomServiceListener(mRoomListener);
        proxy().createRoom(config().getUserToken(),
                mNameEdit.getText().toString(),
                RoomBgUtil.indexToString(mBackgroundSelected),
                Const.ROOM_DURATION,
                Const.ROOM_MAX_AUDIENCE);
    }

    private boolean isRoomNameValid() {
        return mNameEdit.getText() != null && !TextUtils.isEmpty(mNameEdit.getText());
    }

    private void closePolicyNotification() {
        RelativeLayout layout = findViewById(R.id.live_prepare_policy_caution_layout);
        if (layout != null && layout.getParent() != null) {
            ((ViewGroup)layout.getParent()).removeView(layout);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        removePolicyCloseRunnable();
        proxy().removeRoomServiceListener(mRoomListener);
    }
}
