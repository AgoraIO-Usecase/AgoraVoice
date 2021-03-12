package io.agora.agoravoice.ui.activities.main.fragments;

import android.content.Intent;
import android.graphics.Outline;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewOutlineProvider;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatTextView;

import io.agora.agoravoice.R;
import io.agora.agoravoice.ui.activities.SceneActivity;
import io.agora.agoravoice.utils.Const;
import io.agora.agoravoice.utils.WindowUtil;

public class MainFragmentHome extends AbsMainFragment implements View.OnClickListener {
    private int mCardMargin;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mCardMargin = getResources().getDimensionPixelOffset(R.dimen.main_entry_card_margin);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View layout = LayoutInflater.from(getContext())
                .inflate(R.layout.fragment_home, container, false);
        adjustScreen(layout);

        RelativeLayout introLayout = layout.findViewById(R.id.entry_chat_room_layout);
        introLayout.setClipToOutline(true);
        introLayout.setOutlineProvider(new ContentViewOutline());

        layout.findViewById(R.id.chat_room_scene_btn).setOnClickListener(this);

        return layout;
    }

    private void adjustScreen(View layout) {
        AppCompatTextView titleText = layout.findViewById(R.id.main_app_title);
        if (titleText != null) {
            RelativeLayout.LayoutParams params =
                    (RelativeLayout.LayoutParams) titleText.getLayoutParams();
            params.topMargin += WindowUtil.getStatusBarHeight(getContext());
            titleText.setLayoutParams(params);
        }

        RelativeLayout introLayout = layout.findViewById(R.id.entry_chat_room_layout);
        if (introLayout != null) {
            RelativeLayout.LayoutParams params =
                    (RelativeLayout.LayoutParams) introLayout.getLayoutParams();
            params.leftMargin = mCardMargin;
            params.rightMargin = mCardMargin;
            params.bottomMargin = mCardMargin;
            introLayout.setLayoutParams(params);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.chat_room_scene_btn:
                gotoActivity();
                break;
        }
    }

    private void gotoActivity() {
        Intent intent = new Intent(getContext(), SceneActivity.class);
        intent.putExtra(Const.KEY_SCENE_TYPE_NAME, getString(R.string.scene_type_chat_room));
        startActivity(intent);
    }

    private class ContentViewOutline extends ViewOutlineProvider {
        @Override
        public void getOutline(View view, Outline outline) {
            Rect rect = new Rect();
            view.getDrawingRect(rect);
            int radius = getResources().getDimensionPixelOffset(R.dimen.corner_5);
            outline.setRoundRect(rect, radius);
        }
    }
}
