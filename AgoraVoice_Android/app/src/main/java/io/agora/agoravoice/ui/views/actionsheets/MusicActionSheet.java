package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.graphics.Color;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SeekBar;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatSeekBar;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

import io.agora.agoravoice.R;
import io.agora.agoravoice.business.definition.struct.MusicInfo;

public class MusicActionSheet extends AbstractActionSheet {
    private static final int HINT_COLOR = Color.parseColor("#FFababab");
    private static final int LINK_COLOR = Color.parseColor("#0088EB");

    private static final int MAX_VOLUME = 100;

    public interface MusicActionSheetListener {
        void onActionSheetMusicSelected(int index, String name, String url);
        void onVolumeChanged(int progress);
        void onActionSheetMusicStopped();
        void onActionSheetClosed();
    }

    private BgMusicAdapter mAdapter;
    private AppCompatSeekBar mSeekBar;
    private int mSelected = -1;

    private MusicActionSheetListener mListener;

    public MusicActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.action_sheet_music, this);
        RecyclerView recyclerView = findViewById(R.id.action_sheet_music_recycler);
        recyclerView.setLayoutManager(new LinearLayoutManager(
                getContext(), RecyclerView.VERTICAL, false));
        mAdapter = new BgMusicAdapter();
        recyclerView.setAdapter(mAdapter);
        showCredit();

        findViewById(R.id.action_sheet_background_back).setOnClickListener(view -> {
            if (mListener != null) {
                mListener.onActionSheetClosed();
            }
        });

        mSeekBar = findViewById(R.id.action_sheet_music_volume_progress_bar);
        mSeekBar.setMax(MAX_VOLUME);
        mSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (mListener != null) {
                    mListener.onVolumeChanged(progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
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

    public void setCurrentMusicIndex(int index) {
        mSelected = index;
    }

    /**
     * @param volume between 1 and 100, 100 means the original
     *               volume of the music
     */
    public void setCurrentVolume(int volume) {
        mSeekBar.setProgress(volume < 0 ? 0 : Math.min(volume, MAX_VOLUME));
    }

    private class BgMusicAdapter extends RecyclerView.Adapter<MusicViewHolder> {
        private List<MusicInfo> mMusicList = application().config().getMusicInfo();

        @NonNull
        @Override
        public MusicViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).
                    inflate(R.layout.action_sheet_music_item, parent, false);
            return new MusicViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull MusicViewHolder holder, int position) {
            MusicInfo info = mMusicList.get(position);
            holder.setMusicInfo(info.getMusicName(), info.getSinger());
            holder.setPosition(position);
            holder.setPlaying(mSelected == position);
        }

        @Override
        public int getItemCount() {
            return mMusicList == null ? 0 : mMusicList.size();
        }
    }

    private class MusicViewHolder extends RecyclerView.ViewHolder {
        private AppCompatTextView mTitle;
        private AppCompatTextView mArtist;
        private int mPosition;

        MusicViewHolder(@NonNull View itemView) {
            super(itemView);
            mTitle = itemView.findViewById(R.id.live_room_action_sheet_bg_music_title);
            mArtist = itemView.findViewById(R.id.live_room_action_sheet_bg_music_artist);
            itemView.setOnClickListener(view -> {
                if (mPosition == mSelected) {
                    mSelected = -1;
                    if (mListener != null) mListener.onActionSheetMusicStopped();
                } else {
                    mSelected = mPosition;
                    MusicInfo info = application().config().getMusicInfo().get(mPosition);
                    if (mListener != null) {
                        mListener.onActionSheetMusicSelected(mPosition,
                                info.getMusicName(), info.getUrl());
                    }
                }

                application().config().setCurMusicIndex(mSelected);
                mAdapter.notifyDataSetChanged();
            });
        }

        void setMusicInfo(String title, String singer) {
            mTitle.setText(title);
            mArtist.setText(singer);
        }

        void setPosition(int position) {
            mPosition = position;
        }

        void setPlaying(boolean isPlaying) {
            itemView.setActivated(isPlaying);
        }
    }

    public void setMusicActionSheetListener(MusicActionSheetListener listener) {
        mListener = listener;
    }
}
