package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.agoravoice.R;

public class ChatRoomHostPanel extends RelativeLayout {
    private static final int GRID_COUNT = 4;
    private static final int SEAT_COUNT = 8;

    private AppCompatImageView mOwnerImage;
    private AppCompatTextView mOwnerName;

    private SeatAdapter mAdapter;

    public ChatRoomHostPanel(Context context) {
        super(context);
        init();
    }

    public ChatRoomHostPanel(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.chat_room_host_panel, this);
        mOwnerImage = findViewById(R.id.chat_room_host_panel_owner_image);
        mOwnerName = findViewById(R.id.chat_room_host_panel_owner_name);
        RecyclerView seatRecycler = findViewById(R.id.chat_room_host_panel_seat_layout);
        seatRecycler.setLayoutManager(new GridLayoutManager(getContext(), GRID_COUNT));
        mAdapter = new SeatAdapter();
        seatRecycler.setAdapter(mAdapter);
    }

    private class SeatAdapter extends RecyclerView.Adapter<SeatViewHolder> {
        @NonNull
        @Override
        public SeatViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SeatViewHolder(LayoutInflater.from(getContext())
                    .inflate(R.layout.chat_room_host_panel_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull SeatViewHolder holder, int position) {

        }

        @Override
        public int getItemCount() {
            return SEAT_COUNT;
        }
    }

    private class SeatViewHolder extends RecyclerView.ViewHolder {
        public SeatViewHolder(@NonNull View itemView) {
            super(itemView);
        }
    }
}
