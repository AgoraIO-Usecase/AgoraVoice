package io.agora.agoravoice.ui.activities;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatEditText;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.agora.agoravoice.R;
import io.agora.agoravoice.ui.views.actionsheets.AbstractActionSheet;
import io.agora.agoravoice.ui.views.actionsheets.ActionSheetManager;
import io.agora.agoravoice.utils.WindowUtil;

public abstract class AbsLiveActivity extends BaseActivity {
    private static final int IDEAL_MIN_KEYBOARD_HEIGHT = 200;
    private static final int PERMISSION_REQ = 1;

    private static final String[] PERMISSIONS = {
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };

    protected InputMethodManager mInputMethodManager;
    private Rect mDecorViewRect;
    private int mInputMethodHeight;

    private ActionSheetManager mActionSheetManager;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowUtil.hideStatusBar(getWindow(), false);
        mActionSheetManager = new ActionSheetManager();
        mInputMethodManager = (InputMethodManager)
            getSystemService(Context.INPUT_METHOD_SERVICE);
    }

    protected void detectKeyboard() {
        getWindow().getDecorView().getViewTreeObserver()
                .addOnGlobalLayoutListener(this::detectKeyboardLayout);
    }

    protected void stopDetectKeyboard() {
        getWindow().getDecorView().getViewTreeObserver()
                .removeOnGlobalLayoutListener(this::detectKeyboardLayout);
    }

    private void detectKeyboardLayout() {
        Rect rect = new Rect();
        getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);

        if (mDecorViewRect == null) {
            mDecorViewRect = rect;
        }

        int diff = mDecorViewRect.height() - rect.height();
        if (diff == mInputMethodHeight) {
            // Input method keeps showing (and the height does
            // not change), or input method keeps hidden.
            return;
        }

        if (diff > IDEAL_MIN_KEYBOARD_HEIGHT) {
            mInputMethodHeight = diff;
            onInputMethodToggle(true, diff);
        } else if (mInputMethodHeight > 0) {
            mInputMethodHeight = 0;
            onInputMethodToggle(false, mInputMethodHeight);
        }
    }

    protected void onInputMethodToggle(boolean shown, int height) {

    }

    protected void showInputMethodWithView(AppCompatEditText editText) {
        mInputMethodManager.showSoftInput(editText, 0);
    }

    protected void hideInputMethodWithView(AppCompatEditText editText) {
        mInputMethodManager.hideSoftInputFromWindow(editText.getWindowToken(), 0);
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

    protected void checkPermissions() {
        if (!permissionArrayGranted()) {
            ActivityCompat.requestPermissions(this, PERMISSIONS, PERMISSION_REQ);
        } else {
            onAllPermissionsGranted();
        }
    }

    private boolean permissionGranted(String permission) {
        return ContextCompat.checkSelfPermission(
                this, permission) == PackageManager.PERMISSION_GRANTED;
    }

    private boolean permissionArrayGranted() {
        boolean granted = true;
        for (String per : PERMISSIONS) {
            if (!permissionGranted(per)) {
                granted = false;
                break;
            }
        }
        return granted;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSION_REQ) {
            if (permissionArrayGranted()) {
                onAllPermissionsGranted();
            } else {
                Toast.makeText(this, R.string.permission_not_granted, Toast.LENGTH_LONG).show();
                finish();
            }
        }
    }

    private void onAllPermissionsGranted() {

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopDetectKeyboard();
    }
}
