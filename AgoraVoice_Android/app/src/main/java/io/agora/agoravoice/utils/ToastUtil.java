package io.agora.agoravoice.utils;

import android.content.Context;
import android.widget.Toast;

public class ToastUtil {
    public static void showShortToast(Context context, int res) {
        Toast.makeText(context, res, Toast.LENGTH_SHORT).show();
    }

    public static void showShortToast(Context context, String message) {
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
    }
}
