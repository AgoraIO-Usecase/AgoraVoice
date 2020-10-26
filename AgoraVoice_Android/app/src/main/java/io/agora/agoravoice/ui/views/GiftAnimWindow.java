package io.agora.agoravoice.ui.views;

import android.app.Dialog;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.vectordrawable.graphics.drawable.Animatable2Compat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.load.resource.gif.GifDrawable;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;

public class GiftAnimWindow extends Dialog {
    private static final String TAG = GiftAnimWindow.class.getSimpleName();
    private int mResource;

    public GiftAnimWindow(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    public void setAnimResource(int resource) {
        mResource = resource;
    }

    @Override
    public void show() {
        FrameLayout layout = new FrameLayout(getContext());
        AppCompatImageView imageView = new AppCompatImageView(getContext());
        layout.addView(imageView);
        setContentView(layout);

        // The animation runs only once and does not want to cache
        // the state of last time running.
        Glide.with(getContext()).asGif().skipMemoryCache(true)
                .load(mResource).listener(new RequestListener<GifDrawable>() {
            @Override
            public boolean onLoadFailed(@Nullable GlideException e, Object model,
                                        Target<GifDrawable> target, boolean isFirstResource) {
                return false;
            }

            @Override
            public boolean onResourceReady(GifDrawable resource, Object model,
                                           Target<GifDrawable> target, DataSource dataSource, boolean isFirstResource) {
                resource.setLoopCount(1);
                resource.registerAnimationCallback(new Animatable2Compat.AnimationCallback() {
                    public void onAnimationEnd(Drawable drawable) {
                        dismiss();
                    }
                });
                return false;
            }
        }).into(imageView);
        super.show();
    }
}
