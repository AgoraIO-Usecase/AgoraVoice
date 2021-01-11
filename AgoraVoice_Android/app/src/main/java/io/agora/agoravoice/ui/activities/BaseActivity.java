package io.agora.agoravoice.ui.activities;

import android.app.Dialog;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.os.Bundle;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.view.WindowManager;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatTextView;

import io.agora.agoravoice.AgoraApplication;
import io.agora.agoravoice.Config;
import io.agora.agoravoice.R;
import io.agora.agoravoice.manager.ProxyManager;
import io.agora.agoravoice.utils.WindowUtil;

public abstract class BaseActivity extends AppCompatActivity {
    protected int systemBarHeight;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setGlobalLayoutListener();
        systemBarHeight = WindowUtil.getStatusBarHeight(this);
    }

    private void setGlobalLayoutListener() {
        final View layout = findViewById(Window.ID_ANDROID_CONTENT);
        ViewTreeObserver observer = layout.getViewTreeObserver();
        observer.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                layout.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                onGlobalLayoutCompleted();
            }
        });
    }

    protected void onGlobalLayoutCompleted() {

    }

    protected void keepScreenOn(Window window) {
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    protected AgoraApplication application() {
        return (AgoraApplication) getApplication();
    }

    protected ProxyManager proxy() {
        return application().proxy();
    }

    protected SharedPreferences preferences() {
        return application().preferences();
    }

    protected Config config() {
        return application().config();
    }

    protected Dialog showDialog(String title, String message,
                                String positiveText, String negativeText,
                                final Runnable positiveClick,
                                final Runnable negativeClick) {
        final Dialog dialog = new Dialog(this, R.style.dialog_center);
        dialog.setContentView(R.layout.agora_voice_dialog_message);
        AppCompatTextView titleTextView = dialog.findViewById(R.id.dialog_title);
        titleTextView.setText(title);

        AppCompatTextView msgTextView = dialog.findViewById(R.id.dialog_message);
        msgTextView.setText(message);

        AppCompatTextView positiveButton = dialog.findViewById(R.id.dialog_positive_button);
        positiveButton.setText(positiveText);
        positiveButton.setOnClickListener(view -> positiveClick.run());

        AppCompatTextView negativeButton = dialog.findViewById(R.id.dialog_negative_button);
        negativeButton.setText(negativeText);
        negativeButton.setOnClickListener(view -> negativeClick.run());

        WindowUtil.hideStatusBar(dialog.getWindow(), false);
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
        return dialog;
    }

    protected Dialog showDialog(int title, int message,
                                int positiveText, int negativeText,
                                final Runnable positiveClick,
                                final Runnable negativeClick) {
        Resources res = getResources();
        String t = res.getString(title);
        String m = res.getString(message);
        String p = res.getString(positiveText);
        String n = res.getString(negativeText);
        return showDialog(t, m, p, n, positiveClick, negativeClick);
    }

    protected Dialog showDialog(String title,
                                String positiveText, String negativeText,
                                final Runnable positiveClick,
                                final Runnable negativeClick) {
        final Dialog dialog = new Dialog(this, R.style.dialog_center);
        dialog.setContentView(R.layout.agora_voice_dialog);
        AppCompatTextView titleTextView = dialog.findViewById(R.id.dialog_title);
        titleTextView.setText(title);

        AppCompatTextView positiveButton = dialog.findViewById(R.id.dialog_positive_button);
        positiveButton.setText(positiveText);
        positiveButton.setOnClickListener(view -> positiveClick.run());

        AppCompatTextView negativeButton = dialog.findViewById(R.id.dialog_negative_button);
        negativeButton.setText(negativeText);
        negativeButton.setOnClickListener(view -> negativeClick.run());

        WindowUtil.hideStatusBar(dialog.getWindow(), false);
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
        return dialog;
    }

    protected Dialog showDialog(int title,
                                int positiveText, int negativeText,
                                final Runnable positiveClick,
                                final Runnable negativeClick) {
        Resources res = getResources();
        String t = res.getString(title);
        String p = res.getString(positiveText);
        String n = res.getString(negativeText);
        return showDialog(t, p, n, positiveClick, negativeClick);
    }
}
