package io.agora.agoravoice.ui.activities;

import android.graphics.Outline;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewOutlineProvider;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.AvatarUtil;
import io.agora.agoravoice.utils.WindowUtil;

public class AvatarSelectActivity extends BaseActivity implements View.OnClickListener {
    private static final int GRID_COUNT = 3;

    private int mSelected = -1;
    private int mItemCornerRadius;
    private int mGridItemMargin;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowUtil.hideStatusBar(getWindow(), false);
        setContentView(R.layout.activity_edit_avatar);
        initView();

        mItemCornerRadius = getResources().getDimensionPixelOffset(R.dimen.corner_2);
        mGridItemMargin = getResources().getDimensionPixelOffset(R.dimen.margin_2);
    }

    private void initView() {
        findViewById(R.id.main_profile_edit_confirm).setOnClickListener(this);
        findViewById(R.id.main_profile_edit_cancel).setOnClickListener(this);

        RecyclerView recyclerView = findViewById(R.id.main_profile_avatar_recycler);
        recyclerView.setLayoutManager(new GridLayoutManager(this, GRID_COUNT));
        recyclerView.setAdapter(new AvatarEditRecyclerAdapter());
        recyclerView.addItemDecoration(new AvatarItemDecoration());
    }

    @Override
    protected void onGlobalLayoutCompleted() {
        RelativeLayout topLayout = findViewById(R.id.avatar_edit_top_layout);
        if (topLayout != null) {
            RelativeLayout.LayoutParams params =
                    (RelativeLayout.LayoutParams) topLayout.getLayoutParams();
            params.topMargin += systemBarHeight;
            topLayout.setLayoutParams(params);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.main_profile_edit_confirm:
            case R.id.main_profile_edit_cancel:
                break;
        }
    }

    private class AvatarEditRecyclerAdapter extends RecyclerView.Adapter<AvatarEditViewHolder> {
        @NonNull
        @Override
        public AvatarEditViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new AvatarEditViewHolder(LayoutInflater.from(getApplicationContext())
                .inflate(R.layout.avatar_select_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull AvatarEditViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            holder.image.setImageResource(AvatarUtil.getAvatarResByIndex(pos));
            holder.image.setClipToOutline(true);
            holder.image.setOutlineProvider(new AvatarItemViewOutline());

            boolean selected = pos == mSelected;
            holder.mask.setVisibility(selected ? View.VISIBLE : View.GONE);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected) {
                    mSelected = -1;
                } else {
                    mSelected = pos;
                }
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return AvatarUtil.getAvatarCount();
        }
    }

    private static class AvatarEditViewHolder extends RecyclerView.ViewHolder {
        private AppCompatImageView image;
        private RelativeLayout mask;

        public AvatarEditViewHolder(@NonNull View itemView) {
            super(itemView);
            image = itemView.findViewById(R.id.avatar_select_item_image);
            mask = itemView.findViewById(R.id.image_select_item_selected_mask);
        }
    }

    private class AvatarItemDecoration extends RecyclerView.ItemDecoration {
        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                                   @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            super.getItemOffsets(outRect, view, parent, state);
            outRect.set(mGridItemMargin, mGridItemMargin, mGridItemMargin, mGridItemMargin);
        }
    }

    private class AvatarItemViewOutline extends ViewOutlineProvider {
        @Override
        public void getOutline(View view, Outline outline) {
            Rect rect = new Rect();
            view.getDrawingRect(rect);
            outline.setRoundRect(rect, mItemCornerRadius);
        }
    }
}
