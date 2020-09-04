package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.GiftUtil;

public class GiftActionSheet extends AbstractActionSheet implements View.OnClickListener {
    private static final int SPAN_COUNT = 4;
    private static final int COLOR_NORMAL = Color.parseColor("#FFababab");

    public interface GiftActionListener {
        void onGiftSend(int index);
    }

    private GiftActionListener mListener;

    private int mSelected = -1;
    private String[] mGiftNames;
    private String mValueFormat;

    public GiftActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        mGiftNames = getResources().getStringArray(R.array.action_sheet_gift_names);
        mValueFormat = getResources().getString(R.string.gift_action_sheet_value_format);
        LayoutInflater.from(getContext()).inflate(R.layout.action_sheet_gift, this);
        RecyclerView recyclerView = findViewById(R.id.action_sheet_gift_recycler);
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), SPAN_COUNT));
        recyclerView.setAdapter(new GiftAdapter());
        findViewById(R.id.action_sheet_gift_send_btn).setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.action_sheet_gift_send_btn:
                if (mListener != null) {
                    mListener.onGiftSend(mSelected);
                }
                break;
        }
    }

    private class GiftAdapter extends RecyclerView.Adapter<GiftViewHolder> {
        @NonNull
        @Override
        public GiftViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new GiftViewHolder(LayoutInflater.from(getContext()).
                    inflate(R.layout.action_sheet_gift_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull GiftViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            holder.setPosition(position);
            holder.name.setText(mGiftNames[pos]);
            holder.value.setText(String.format(mValueFormat, getValue(pos)));
            holder.icon.setImageResource(GiftUtil.GIFT_ICON_RES[pos]);

            boolean isSelected = mSelected == pos;
            if (isSelected) {
                holder.name.setTextColor(Color.WHITE);
                holder.value.setTextColor(Color.WHITE);
            } else {
                holder.name.setTextColor(COLOR_NORMAL);
                holder.value.setTextColor(COLOR_NORMAL);
            }

            holder.itemView.setActivated(mSelected == position);
            holder.itemView.setOnClickListener(view -> {
                mSelected = position;
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return GiftUtil.GIFT_ICON_RES.length;
        }
    }

    private static class GiftViewHolder extends RecyclerView.ViewHolder {
        AppCompatImageView icon;
        AppCompatTextView name;
        AppCompatTextView value;
        int position;

        GiftViewHolder(@NonNull View itemView) {
            super(itemView);
            icon = itemView.findViewById(R.id.action_sheet_gift_item_icon);
            name = itemView.findViewById(R.id.action_sheet_gift_item_name);
            value = itemView.findViewById(R.id.action_sheet_gift_item_value);
        }

        void setPosition(int position) {
            this.position = position;
        }
    }

    private int getValue(int index) {
        return (index + 2) * 10;
    }

    public void setGiftActionListener(GiftActionListener listener) {
        mListener = listener;
    }
}
