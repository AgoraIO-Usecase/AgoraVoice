package io.agora.agoravoice.utils;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.os.Environment;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.core.graphics.drawable.RoundedBitmapDrawable;
import androidx.core.graphics.drawable.RoundedBitmapDrawableFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class UserUtil {
    private static final String LOG_FOLDER_NAME = "logs";
    private static final String LOG_ZIP_NAME = "agoravoice.logs.zip";

    public static int getUserProfileIcon(String userId) {
        try {
            long intUserId = Long.parseLong(userId);
            int size = Const.AVATAR_RES.length;
            int index = (int) (intUserId % size);
            return Const.AVATAR_RES[index];
        } catch (NumberFormatException e) {
            return Const.AVATAR_RES[0];
        }
    }

    public static RoundedBitmapDrawable getUserRoundIcon(Resources resources, String userId) {
        int res = UserUtil.getUserProfileIcon(userId);
        RoundedBitmapDrawable drawable = RoundedBitmapDrawableFactory.create(
                resources, BitmapFactory.decodeResource(resources, res));
        drawable.setCircular(true);
        return drawable;
    }

    public static int toIntegerUserId(String stringId) {
        try {
            long parsed = Long.parseLong(stringId);
            return (int) (parsed & 0xFFFFFFFFL);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    public static String getUserText(String userId, String userName) {
        return !TextUtils.isEmpty(userName) ? userName : userId;
    }

    public static File appLogFolder(Context context) {
        File folder = new File(context.getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS), LOG_FOLDER_NAME);
        if (!folder.exists() && !folder.mkdirs()) folder = null;
        return folder;
    }

    public static String appLogFolderPath(Context context) {
        File folder = appLogFolder(context);
        return folder != null && folder.exists() ? folder.getAbsolutePath() : "";
    }

    private static String logFilePath(Context context, String name) {
        File folder = appLogFolder(context);
        if (folder != null && !folder.exists() && !folder.mkdir()) return "";
        else return new File(folder, name).getAbsolutePath();
    }

    public static void uploadLogs(Context context) {
        File logFolderFile = appLogFolder(context);
        File targetZipFile = new File(context.getExternalFilesDir(
                Environment.DIRECTORY_DOCUMENTS), LOG_ZIP_NAME);
        boolean create = false;
        if (targetZipFile.exists()) {
             create = targetZipFile.delete();
        }

        if (create && targetZipFile.exists()) {
            try {
                create = targetZipFile.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        if (create) {
            try {
                byte[] buffer = new byte[256];
                compressLogs(logFolderFile, targetZipFile, buffer);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private static void compressLogs(@NonNull File source, @NonNull File target, byte[] buffer) throws Exception {
        ZipOutputStream outStream = new ZipOutputStream(new FileOutputStream(target));
        compressLogFile(source, outStream, buffer);
    }

    private static void compressLogFile(File source, ZipOutputStream target, byte[] buffer) throws Exception {
        if (source.exists() && source.isFile()) {
            target.putNextEntry(new ZipEntry(source.getName()));
            int len;
            FileInputStream in = new FileInputStream(source);
            while ((len = in.read(buffer, 0, buffer.length)) != -1) {
                target.write(buffer, 0, len);
            }
            target.closeEntry();
            in.close();
        } else if (source.exists() && source.isDirectory()) {
            File[] subFiles = source.listFiles();
            if (subFiles != null) {
                for (File file : subFiles) {
                    compressLogs(file, new File(source.getParent(), source.getName() +
                            File.pathSeparator + file.getName()), buffer);
                }
            }
        }
    }
}
