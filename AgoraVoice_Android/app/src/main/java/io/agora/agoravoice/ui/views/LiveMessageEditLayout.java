package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.widget.RelativeLayout;


public class LiveMessageEditLayout extends RelativeLayout {
    public static final int EDIT_TEXT_ID = 1 << 4;
    private static final int HINT_TEXT_COLOR = Color.rgb(96, 96, 96);
    private static final int TEXT_COLOR = Color.rgb(35, 35, 35);
    private static final int BACKGROUND_COLOR = Color.rgb(239, 239, 239);
    private static final int TEXT_SIZE = 14;

    public LiveMessageEditLayout(Context context) {
        super(context);
        init();
    }

    public LiveMessageEditLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public LiveMessageEditLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
//        int margin = getResources().getDimensionPixelSize(R.dimen.activity_horizontal_margin);
//        int padding = getResources().getDimensionPixelSize(R.dimen.live_bottom_edit_padding);
//
//        setBackgroundColor(BACKGROUND_COLOR);
//
//        AppCompatEditText editText = new AppCompatEditText(getContext());
//        editText.setId(EDIT_TEXT_ID);
//        LayoutParams params = new LayoutParams(
//                LayoutParams.MATCH_PARENT,
//                LayoutParams.MATCH_PARENT);
//        params.setMarginStart(margin);
//        params.setMarginEnd(margin);
//        params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE);
//        addView(editText, params);
//
//        editText.setPadding(padding, 0, padding, 0);
//        editText.setHint(R.string.live_bottom_edit_hint);
//        editText.setHintTextColor(HINT_TEXT_COLOR);
//        editText.setTextColor(TEXT_COLOR);
//        editText.setTextSize(TEXT_SIZE);
//        editText.setSingleLine();
//        editText.setImeOptions(EditorInfo.IME_ACTION_DONE);
//        editText.setBackgroundResource(R.drawable.message_edit_text_bg);
    }
}
