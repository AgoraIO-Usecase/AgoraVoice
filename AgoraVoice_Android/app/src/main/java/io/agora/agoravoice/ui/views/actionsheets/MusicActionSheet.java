package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.agoravoice.R;

public class MusicActionSheet extends AbstractActionSheet {
    private static final int HINT_COLOR = Color.parseColor("#FFababab");
    private static final int LINK_COLOR = Color.parseColor("#0088EB");

    public interface BackgroundMusicActionSheetListener {
        void onActionSheetMusicSelected(int index, String name, String url);
        void onActionSheetMusicStopped();
    }

//    private BgMusicAdapter mAdapter;
    private int mPaddingHorizontal;
    private int mDividerHeight;
    private int mSelected = -1;

    private BackgroundMusicActionSheetListener mListener;

    public MusicActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.action_sheet_music, this);
        RecyclerView recyclerView = findViewById(R.id.action_sheet_music_recycler);
        recyclerView.setLayoutManager(new LinearLayoutManager(
                getContext(), RecyclerView.VERTICAL, false));

        showCredit();
    }

    private void showCredit() {
        AppCompatTextView creditView = findViewById(R.id.music_credit);
        String hint = getResources().getString(R.string.action_sheet_music_credit_hint);
        String link = getResources().getString(R.string.action_sheet_music_credit_link);
        String credit = hint + link;
        SpannableString creditSpan = new SpannableString(credit);
        creditSpan.setSpan(new ForegroundColorSpan(HINT_COLOR),
                0, hint.length(), SpannableStringBuilder.SPAN_INCLUSIVE_EXCLUSIVE);
        creditSpan.setSpan(new ForegroundColorSpan(LINK_COLOR),
                hint.length(), credit.length(), SpannableStringBuilder.SPAN_INCLUSIVE_EXCLUSIVE);
        creditView.setText(creditSpan);
    }
//
//    private class BgMusicAdapter extends RecyclerView.Adapter {
//        private List<MusicInfo> mMusicList = application().config().getMusicList();
//
//        @NonNull
//        @Override
//        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
//            View view = LayoutInflater.from(parent.getContext()).
//                    inflate(R.layout.action_background_music_item, parent, false);
//            return new BgMusicViewHolder(view);
//        }
//
//        @Override
//        public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
//            BgMusicViewHolder bgMusicViewHolder = (BgMusicViewHolder) holder;
//            MusicInfo info = mMusicList.get(position);
//            bgMusicViewHolder.setMusicInfo(info.getMusicName(), info.getSinger());
//            bgMusicViewHolder.setPosition(position);
//            bgMusicViewHolder.setPlaying(mSelected == position);
//        }
//
//        @Override
//        public int getItemCount() {
//            return mMusicList == null ? 0 : mMusicList.size();
//        }
//    }
//
//    private class MusicViewHolder extends RecyclerView.ViewHolder {
//        private AppCompatTextView mTitle;
//        private AppCompatTextView mArtist;
//        private int mPosition;
//
//        MusicViewHolder(@NonNull View itemView) {
//            super(itemView);
//            mTitle = itemView.findViewById(R.id.live_room_action_sheet_bg_music_title);
//            mArtist = itemView.findViewById(R.id.live_room_action_sheet_bg_music_artist);
//            itemView.setOnClickListener(view -> {
//                if (mPosition == mSelected) {
//                    mSelected = -1;
//                    if (mListener != null) mListener.onActionSheetMusicStopped();
//                } else {
//                    mSelected = mPosition;
//                    MusicInfo info = application().config().getMusicList().get(mPosition);
//                    if (mListener != null) {
//                        mListener.onActionSheetMusicSelected(mPosition,
//                                info.getMusicName(), info.getUrl());
//                    }
//                }
//
//                application().config().setCurrentMusicIndex(mSelected);
//                mAdapter.notifyDataSetChanged();
//            });
//        }
//
//        void setMusicInfo(String title, String singer) {
//            mTitle.setText(title);
//            mArtist.setText(singer);
//        }
//
//        void setPosition(int position) {
//            mPosition = position;
//        }
//
//        void setPlaying(boolean isPlaying) {
//            itemView.setActivated(isPlaying);
//        }
//    }

    private class LineDecorator extends RecyclerView.ItemDecoration {
        @Override
        public void onDrawOver(@NonNull Canvas c,
                               @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            Rect rect = new Rect();
            Paint paint = new Paint();
            paint.setColor(Color.parseColor("#FFababab"));

            int count = parent.getChildCount();
            for (int i = 0; i < count; i++) {
                if (mSelected == i + 1) {
                    continue;
                }

                View child = parent.getChildAt(i);
                child.getDrawingRect(rect);
                int startX = rect.left + mPaddingHorizontal;
                int width = rect.right - rect.left - startX * 2;
                int height = rect.bottom - rect.top;
                int startY = height * (i + 1);
                c.drawRect(new Rect(startX, startY,
                        startX + width, startY + mDividerHeight), paint);
            }
        }
    }
}
