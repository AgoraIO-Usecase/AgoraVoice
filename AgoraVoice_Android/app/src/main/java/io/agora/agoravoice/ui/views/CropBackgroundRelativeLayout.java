package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

public class CropBackgroundRelativeLayout extends RelativeLayout {
    private int mMeasureWidth;
    private int mMeasureHeight;
    private Bitmap mBackground;
    private BitmapDrawable mCropped;

    public CropBackgroundRelativeLayout(Context context) {
        super(context);
    }

    public CropBackgroundRelativeLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int w = MeasureSpec.getSize(widthMeasureSpec);
        int h = MeasureSpec.getSize(heightMeasureSpec);

        if (mMeasureWidth != w || mMeasureHeight != h) {
            mMeasureWidth = w;
            mMeasureHeight = h;
            if (mBackground != null) {
                adjustSize(mMeasureWidth, mMeasureHeight);
            }
        }
    }

    public void setCropBackground(int res) {
        if (mBackground != null) {
            mBackground.recycle();
        }

        mBackground = BitmapFactory.decodeResource(getResources(), res);
        adjustSize(mMeasureWidth, mMeasureHeight);
    }

    private void adjustSize(int width, int height) {
        if (mBackground == null) return;
        if (width <= 0 || height <= 0) return;

        int w = mBackground.getWidth();
        int h = mBackground.getHeight();

        float ratioRes = w / (float) h;
        float ratioNow = width / (float) height;

        int x;
        int y;
        int croppedWidth;
        int croppedHeight;
        if (ratioRes <= ratioNow) {
            // the resource image is thinner than the view,
            // the image should be cropped from top and bottom
            int cropH = (int) (w / ratioNow);
            x = 0;
            y = (h - cropH) / 2;
            croppedWidth = w;
            croppedHeight = cropH;
        } else {
            // the resource image is flatter than the view,
            // the image should be cropped from both sides
            int cropW = (int) (h * ratioNow);
            x = (w - cropW) / 2;
            y = 0;
            croppedWidth = cropW;
            croppedHeight = h;
        }

        Bitmap cropped = Bitmap.createBitmap(mBackground, x, y, croppedWidth, croppedHeight);
        if (mCropped != null && !mCropped.getBitmap().isRecycled()) {
            mCropped.getBitmap().recycle();
        }

        mCropped = new BitmapDrawable(getResources(), cropped);
        setBackground(mCropped);
    }
}
