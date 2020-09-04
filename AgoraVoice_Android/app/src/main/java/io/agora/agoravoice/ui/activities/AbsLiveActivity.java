package io.agora.agoravoice.ui.activities;

import android.os.Bundle;

import io.agora.agoravoice.ui.views.actionsheets.AbstractActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.ActionSheetManager;
import io.agora.agoravoice.utils.WindowUtil;

public abstract class AbsLiveActivity extends BaseActivity {
    private ActionSheetManager mActionSheetManager;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowUtil.hideStatusBar(getWindow(), false);
        mActionSheetManager = new ActionSheetManager();
    }

    protected void showActionSheet(AbstractActionSheet actionSheet, boolean newStack) {
        mActionSheetManager.showActionSheetDialog(this, actionSheet, newStack);
    }

    protected AbstractActionSheet createActionSheet(ActionSheetManager.ActionSheet sheet) {
        return mActionSheetManager.createActionSheet(this, sheet);
    }

    protected boolean actionSheetShowing() {
        return mActionSheetManager.actionSheetShowing();
    }

    protected void closeActionSheet() {
        mActionSheetManager.dismissActionSheetDialog();
    }
}
