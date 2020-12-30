package io.agora.agoravoice.utils;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;

public class ClipboardUtils {
    public static void copyText(Context context, String label, String text) {
        ClipboardManager manager = (ClipboardManager) context
                .getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData data = ClipData.newPlainText(label, text);
        manager.setPrimaryClip(data);
    }
}
