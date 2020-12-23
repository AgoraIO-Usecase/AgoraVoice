package io.agora.agoravoice.utils;

import android.content.Context;
import android.content.pm.PackageManager;

public class AppUtil {
    public static String getAppVersion(Context context) {
        try {
            return context.getPackageManager().getPackageInfo(
                    context.getPackageName(), 0).versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }
}
