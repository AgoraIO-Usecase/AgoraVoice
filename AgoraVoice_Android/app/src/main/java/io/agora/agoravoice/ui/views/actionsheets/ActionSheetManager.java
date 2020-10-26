package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import com.google.android.material.bottomsheet.BottomSheetDialog;

import java.util.Stack;

import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.WindowUtil;

public class ActionSheetManager {
    public enum ActionSheet {
        background,
        sound_effect,
        voice_beauty,
        tool,
        gift,
        music,
        user,
        seat_op,
        three_dimen_voice
    }

    private BottomSheetDialog mCurrentActionSheet;
    private Stack<AbstractActionSheet> mActionSheetStack = new Stack<>();

    public void showActionSheetDialog(Context context, AbstractActionSheet actionSheet, boolean newStack) {
        if (newStack) mActionSheetStack.clear();
        mActionSheetStack.push(actionSheet);
        showActionSheet(context, actionSheet);
    }

    private void showActionSheet(Context context, View contentView) {
        dismissActionSheetDialog();

        mCurrentActionSheet = new BottomSheetDialog(context, R.style.agora_voice_base_dialog);
        mCurrentActionSheet.setCanceledOnTouchOutside(true);
        mCurrentActionSheet.setContentView(contentView);
        mCurrentActionSheet.setDismissWithAnimation(true);

        if (mCurrentActionSheet.getWindow() != null) {
            WindowUtil.hideStatusBar(mCurrentActionSheet.getWindow(), false);
        }

        mCurrentActionSheet.setOnDismissListener(dialog ->  {
            if (mActionSheetStack.isEmpty()) {
                // Happens only in case of errors.
                return;
            }

            if (contentView != mActionSheetStack.peek()) {
                // When this action sheet is not at the top of
                // stack, it means that a new action sheet
                // is about to be shown and it needs a fallback
                // history, and this sheet needs to be retained.
                return;
            }

            // At this moment, we want to fallback to
            // the previous action sheet if exists.
            mActionSheetStack.pop();
            if (!mActionSheetStack.isEmpty()) {
                AbstractActionSheet sheet = mActionSheetStack.peek();
                ((ViewGroup) sheet.getParent()).removeAllViews();
                showActionSheet(context, mActionSheetStack.peek());
            }
        });

        mCurrentActionSheet.show();
    }

    public void dismissActionSheetDialog() {
        if (mCurrentActionSheet != null && mCurrentActionSheet.isShowing()) {
            mCurrentActionSheet.dismiss();
            mCurrentActionSheet = null;
        }
    }

    public boolean actionSheetShowing() {
        return mCurrentActionSheet != null && mCurrentActionSheet.isShowing();
    }

    public AbstractActionSheet createActionSheet(Context context, ActionSheet actionSheet) {
        switch (actionSheet) {
            case background: return new BackgroundActionSheet(context);
            case sound_effect: return new SoundEffectActionSheet(context);
            case voice_beauty: return new VoiceBeautyActionSheet(context);
            case tool: return new ToolActionSheet(context);
            case gift: return new GiftActionSheet(context);
            case music: return new MusicActionSheet(context);
            case user: return new UserListActionSheet(context);
            case seat_op: return new HostPanelOperateActionSheet(context);
            case three_dimen_voice: return new ThreeDimenVoiceActionSheet(context);
            default: return null;
        }
    }
}
