package io.agora.agoravoice.utils;

import android.app.Dialog;
import android.content.Context;
import android.content.res.Resources;

import androidx.appcompat.widget.AppCompatTextView;

import io.agora.agoravoice.R;

public class DialogUtil {
    public static Dialog showDialog(Context context, String title, String message,
                                    String positiveText, String negativeText,
                                    final Runnable positiveClick,
                                    final Runnable negativeClick) {
        final Dialog dialog = new Dialog(context, R.style.dialog_center);
        dialog.setContentView(R.layout.agora_voice_dialog);
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

    public static Dialog showDialog(Context context, int title, int message,
                                int positiveText, int negativeText,
                                final Runnable positiveClick,
                                final Runnable negativeClick) {
        Resources res = context.getResources();
        String t = res.getString(title);
        String m = res.getString(message);
        String p = res.getString(positiveText);
        String n = res.getString(negativeText);
        return showDialog(context, t, m, p, n, positiveClick, negativeClick);
    }
}
