package io.agora.agoravoice.utils;

import android.content.Context;

import java.util.Locale;
import java.util.Random;

import io.agora.agoravoice.R;

public class RandomUtil {
    private static int sLastIndex;

    public static String randomLiveRoomName(Context context) {
        String[] ROOM_NAMES = context.getResources().getStringArray(R.array.random_channel_names);

        int length = ROOM_NAMES.length;
        int thisIndex = sLastIndex;
        while (thisIndex == sLastIndex) {
            thisIndex = (int) (Math.random() * length);
        }

        sLastIndex = thisIndex;
        return ROOM_NAMES[sLastIndex];
    }

    public static String randomUserName(Context context) {
        Locale defaultLocale = Locale.getDefault();
        if (defaultLocale.getLanguage().equals("en")) {
            return String.format(defaultLocale, "%s %s",
                    getRandomName(context), getRandomSurname(context));
        }
        return String.format(defaultLocale, "%s%s",
                getRandomSurname(context), getRandomName(context));
    }

    private static String getRandomSurname(Context context) {
        Random random = new Random(System.currentTimeMillis());
        String[] surnames = context.getResources().getStringArray(R.array.random_surnames);
        return surnames[random.nextInt(surnames.length - 1)];
    }

    private static String getRandomName(Context context) {
        Random random = new Random(System.currentTimeMillis());
        String[] names = context.getResources().getStringArray(R.array.random_names);
        return names[random.nextInt(names.length - 1)];
    }
}
