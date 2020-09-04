package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;

public class RoomIntroImageView extends AppCompatImageView {
    private static final int WIDTH_REF = 155;
    private static final int HEIGHT_REF = 204;

    public RoomIntroImageView(@NonNull Context context) {
        super(context);
    }

    public RoomIntroImageView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int width = MeasureSpec.getSize(widthMeasureSpec);
        int height = (int)(((float) width) * HEIGHT_REF / WIDTH_REF);
        setMeasuredDimension(width, height);
        int heightSpec = MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY);
        super.onMeasure(widthMeasureSpec, heightSpec);
    }
}
