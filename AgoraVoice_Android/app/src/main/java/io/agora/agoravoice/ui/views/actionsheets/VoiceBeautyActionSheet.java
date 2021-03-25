package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.agoravoice.Config;
import io.agora.agoravoice.R;
import io.agora.agoravoice.manager.AudioManager;
import io.agora.agoravoice.utils.VoiceUtil;

public class VoiceBeautyActionSheet extends AbstractActionSheet implements View.OnClickListener {
    public interface VoiceBeautyActionListener {
        void onVoiceBeautySelected(int type);
        void onVoiceBeautyUnselected();
    }

    private static final int TITLE_TEXT_DEFAULT = Color.parseColor("#FFababab");

    private static final int TYPE_CHAT = 0;
    private static final int TYPE_SING = 1;
    private static final int TYPE_TIMBRE = 2;

    private static final int GRID_COUNT_THREE = 3;
    private static final int GRID_COUNT_FOUR = 4;

    private int mCurrentType = -1;

    private AppCompatTextView[] mTypeTexts;
    private View[] mIndicators;

    private int mSelected1 = -1;
    private int mSelected2 = -1;
    private int mSelected3 = -1;

    private RecyclerView mRecyclerView;
    private RecyclerView.Adapter<?> mCurrentAdapter;
    private final TextItemDecoration mTextItemDecoration = new TextItemDecoration();

    private String[] mVoiceBeautyChatNames;
    private String[] mVoiceBeautySingNames;
    private String[] mVoiceBeautyTimbreNames;

    private RelativeLayout mVoiceBeautyLayout1;
    private RelativeLayout mVoiceBeautyLayout2;
    private RelativeLayout mVoiceBeautyLayout3;

    private VoiceBeautyActionListener mListener;

    private Config mConfig;

    public VoiceBeautyActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.action_sheet_voice_beauty, this);

        mVoiceBeautyLayout1 = findViewById(R.id.action_sheet_voice_beauty_layout_1);
        mVoiceBeautyLayout1.setOnClickListener(this);
        mVoiceBeautyLayout2 = findViewById(R.id.action_sheet_voice_beauty_layout_2);
        mVoiceBeautyLayout2.setOnClickListener(this);
        mVoiceBeautyLayout3 = findViewById(R.id.action_sheet_voice_beauty_layout_3);
        mVoiceBeautyLayout3.setOnClickListener(this);

        mTypeTexts = new AppCompatTextView[3];
        mTypeTexts[0] = findViewById(R.id.action_sheet_sound_effect_type_item_name);
        mTypeTexts[1] = findViewById(R.id.action_sheet_voice_beauty_type_2);
        mTypeTexts[2] = findViewById(R.id.action_sheet_voice_beauty_type_3);

        mIndicators = new View[3];
        mIndicators[0] = findViewById(R.id.action_sheet_sound_effect_type_item_indicator);
        mIndicators[1] = findViewById(R.id.action_sheet_voice_beauty_type_indicator_2);
        mIndicators[2] = findViewById(R.id.action_sheet_voice_beauty_type_indicator_3);

        mVoiceBeautyChatNames = getResources().getStringArray(R.array.voice_beauty_chat_names);
        mVoiceBeautyTimbreNames = getResources().getStringArray(R.array.voice_beauty_timbre);

        // May change in late version updates
        mVoiceBeautySingNames = getResources().getStringArray(R.array.voice_beauty_sing_names_simple);

        mRecyclerView = findViewById(R.id.action_sheet_voice_beauty_recycler);
        changeType(TYPE_CHAT);
    }

    public void setVoiceBeautyActionListener(VoiceBeautyActionListener listener) {
        mListener = listener;
    }

    public void setConfig(Config config) {
        mConfig = config;
        changeType(mCurrentType);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == mVoiceBeautyLayout1.getId()) {
            changeType(TYPE_CHAT);
        } else if (id == mVoiceBeautyLayout2.getId()) {
            changeType(TYPE_SING);
        } else if (id == mVoiceBeautyLayout3.getId()) {
            changeType(TYPE_TIMBRE);
        }
    }

    private void changeType(int type) {
        mCurrentType = type;
        mRecyclerView.setAdapter(null);
        mRecyclerView.setLayoutManager(layoutManager(mCurrentType));
        mRecyclerView.removeItemDecoration(mTextItemDecoration);
        highlightSelectedTab();

        mSelected1 = -1;
        mSelected2 = -1;
        mSelected3 = -1;

        switch (mCurrentType) {
            case TYPE_CHAT:
                mSelected1 = getSelectedItem();
                mCurrentAdapter = new ChatBeautyAdapter();
                break;
            case TYPE_SING:
                mSelected2 = getSelectedItem();
                mCurrentAdapter = new SingBeautyAdapter2();
                mRecyclerView.addItemDecoration(mTextItemDecoration);
                break;
            case TYPE_TIMBRE:
                mSelected3 = getSelectedItem();
                mCurrentAdapter = new VoiceTimbreAdapter();
                mRecyclerView.addItemDecoration(mTextItemDecoration);
                break;
        }

        mRecyclerView.setAdapter(mCurrentAdapter);
        mCurrentAdapter.notifyDataSetChanged();
    }

    private void highlightSelectedTab() {
        int index = mCurrentType;
        for (int i = 0; i < mTypeTexts.length; i++) {
            if (i == index) {
                mTypeTexts[i].setTextColor(Color.WHITE);
                mIndicators[i].setVisibility(VISIBLE);
            } else {
                mTypeTexts[i].setTextColor(TITLE_TEXT_DEFAULT);
                mIndicators[i].setVisibility(GONE);
            }
        }
    }

    private RecyclerView.LayoutManager layoutManager(int type) {
        int gridCount;
        if (type == TYPE_TIMBRE) {
            gridCount = GRID_COUNT_FOUR;
        } else if (type == TYPE_CHAT || type == TYPE_SING) {
            gridCount = GRID_COUNT_THREE;
        } else {
            gridCount = 0;
        }

        return new GridLayoutManager(getContext(), gridCount);
    }

    private int getSelectedType(int position) {
        switch (mCurrentType) {
            case TYPE_CHAT:
                return AudioManager.EFFECT_MALE_MAGNETIC + position;
            case TYPE_SING:
                return AudioManager.EFFECT_MALE_HALL + position;
            case TYPE_TIMBRE:
                return AudioManager.EFFECT_TIMBRE_VIGOROUS + position;
            default: return -1;
        }
    }

    private int getSelectedItem() {
        int type = mConfig == null ? -1 : mConfig.getCurAudioEffect();
        if (type == -1) return -1;

        switch (mCurrentType) {
            case TYPE_CHAT:
                if (AudioManager.EFFECT_MALE_MAGNETIC <= type &&
                    type <= AudioManager.EFFECT_FEMALE_VITALITY) {
                    return type - AudioManager.EFFECT_MALE_MAGNETIC;
                } else {
                    return -1;
                }
            case TYPE_SING:
                if (AudioManager.EFFECT_MALE_HALL <= type &&
                        type <= AudioManager.EFFECT_FEMALE_SMALL_ROOM) {
                    // currently only 3 options for room effect
                    return (type - AudioManager.EFFECT_MALE_HALL) / 3;
                } else {
                    return -1;
                }
            case TYPE_TIMBRE:
                if (AudioManager.EFFECT_TIMBRE_VIGOROUS <= type &&
                        type <= AudioManager.EFFECT_TIMBRE_RINGING) {
                    return type - AudioManager.EFFECT_TIMBRE_VIGOROUS;
                } else {
                    return -1;
                }
            default: return -1;
        }
    }

    private class ChatBeautyAdapter extends RecyclerView.Adapter<ChatBeautyViewHolder> {
        @NonNull
        @Override
        public ChatBeautyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new ChatBeautyViewHolder(LayoutInflater.from(getContext())
                .inflate(R.layout.action_sheet_voice_beauty_item_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull ChatBeautyViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == mSelected1;

            holder.image.setImageResource(VoiceUtil.VOICE_BEAUTY_CHAT_RES[pos]);
            holder.name.setText(mVoiceBeautyChatNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.itemView.setActivated(selected);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected1) {
                    mSelected1 = -1;
                    if (mListener != null) {
                        mListener.onVoiceBeautyUnselected();
                    }
                } else {
                    mSelected1 = pos;
                    if (mListener != null) {
                        mListener.onVoiceBeautySelected(
                                getSelectedType(pos));
                    }
                }
                mCurrentAdapter.notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return VoiceUtil.VOICE_BEAUTY_CHAT_PARAMS.length;
        }
    }

    private static class ChatBeautyViewHolder extends RecyclerView.ViewHolder {
        AppCompatImageView image;
        AppCompatTextView name;

        public ChatBeautyViewHolder(@NonNull View itemView) {
            super(itemView);

            image = itemView.findViewById(R.id.action_sheet_voice_beauty_item_icon);
            name = itemView.findViewById(R.id.action_sheet_voice_beauty_item_name);
        }
    }

    private class SingBeautyAdapter extends RecyclerView.Adapter<SingBeautyViewHolder> {
        @NonNull
        @Override
        public SingBeautyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SingBeautyViewHolder(LayoutInflater.from(getContext())
                    .inflate(R.layout.action_sheet_voice_beauty_item_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull SingBeautyViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == mSelected2;

            holder.image.setImageResource(VoiceUtil.VOICE_BEAUTY_SING_RES[pos]);
            holder.itemView.setActivated(selected);

            // TODO current version of sdk has not support all the sing voice beauty
            // Here we make those that are not supported disabled and cannot be
            // selected as a workaround, should be fixed for later versions of sdk
            if (pos == 0 || pos == 1 || pos == 3 || pos == 4) {
                holder.image.setEnabled(false);
                holder.itemView.setOnClickListener(null);
            } else {
                holder.image.setEnabled(true);
                holder.itemView.setOnClickListener(view -> {
                    if (pos == mSelected2) {
                        mSelected2 = -1;
                        if (mListener != null) {
                            mListener.onVoiceBeautyUnselected();
                        }
                    } else {
                        mSelected2 = pos;
                        if (mListener != null) {
                            mListener.onVoiceBeautySelected(
                                    getSelectedType(pos));
                        }
                    }
                    mCurrentAdapter.notifyDataSetChanged();
                });
            }

            holder.name.setText(mVoiceBeautySingNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
        }

        @Override
        public int getItemCount() {
            return VoiceUtil.VOICE_BEAUTY_SING_RES.length;
        }
    }

    private static class SingBeautyViewHolder extends RecyclerView.ViewHolder {
        AppCompatImageView image;
        AppCompatTextView name;

        public SingBeautyViewHolder(@NonNull View itemView) {
            super(itemView);

            image = itemView.findViewById(R.id.action_sheet_voice_beauty_item_icon);
            name = itemView.findViewById(R.id.action_sheet_voice_beauty_item_name);
        }
    }

    private class SingBeautyAdapter2 extends RecyclerView.Adapter<SingBeautyViewHolder2> {
        @NonNull
        @Override
        public SingBeautyViewHolder2 onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SingBeautyViewHolder2(LayoutInflater.from(getContext()).inflate(
                    R.layout.action_sheet_voice_beauty_item_text_only_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull SingBeautyViewHolder2 holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == mSelected2;
            holder.itemView.setActivated(selected);
            holder.title.setText(mVoiceBeautySingNames[pos]);
            holder.title.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected2) {
                    mSelected2 = -1;
                    if (mListener != null) {
                        mListener.onVoiceBeautyUnselected();
                    }
                } else {
                    mSelected2 = pos;
                    if (mListener != null) {
                        // There will be 6 different sing effects, but currently
                        // there are only two supported. And this is used to
                        // match the 6 remained effect of the audio effect setting.
                        mListener.onVoiceBeautySelected(
                                getSelectedType(pos + 2));
                    }
                }
                mCurrentAdapter.notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return mVoiceBeautySingNames.length;
        }
    }

    private static class SingBeautyViewHolder2 extends RecyclerView.ViewHolder {
        AppCompatTextView title;

        public SingBeautyViewHolder2(@NonNull View itemView) {
            super(itemView);
            title = itemView.findViewById(R.id.action_sheet_voice_beauty_text_item_view);
        }
    }

    private class VoiceTimbreAdapter extends RecyclerView.Adapter<VoiceTimbreViewHolder> {
        @NonNull
        @Override
        public VoiceTimbreViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new VoiceTimbreViewHolder(LayoutInflater.from(getContext()).inflate(
                    R.layout.action_sheet_voice_beauty_item_text_only_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull VoiceTimbreViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == mSelected3;
            holder.name.setText(mVoiceBeautyTimbreNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.layout.setActivated(selected);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected3) {
                    mSelected3 = -1;
                    if (mListener != null) {
                        mListener.onVoiceBeautyUnselected();
                    }
                } else {
                    mSelected3 = pos;
                    if (mListener != null) {
                        mListener.onVoiceBeautySelected(
                                getSelectedType(pos));
                    }
                }
                mCurrentAdapter.notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return mVoiceBeautyTimbreNames.length;
        }
    }

    private static class VoiceTimbreViewHolder extends RecyclerView.ViewHolder {
        RelativeLayout layout;
        AppCompatTextView name;

        public VoiceTimbreViewHolder(@NonNull View itemView) {
            super(itemView);
            layout = itemView.findViewById(R.id.action_sheet_voice_beauty_text_item_layout);
            name = itemView.findViewById(R.id.action_sheet_voice_beauty_text_item_view);
        }
    }

    private class TextItemDecoration extends RecyclerView.ItemDecoration {
        private int mSpacing = getResources().getDimensionPixelOffset(
                R.dimen.action_sheet_voice_beauty_text_item_spacing);

        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                                   @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            super.getItemOffsets(outRect, view, parent, state);
            outRect.set(mSpacing, mSpacing, mSpacing, mSpacing);

            int position = parent.getChildAdapterPosition(view);
            if (position % GRID_COUNT_FOUR + 1 == GRID_COUNT_FOUR) {
                outRect.right = 0;
            }

            if (position < GRID_COUNT_FOUR) {
                outRect.top = 0;
            } else if (position + GRID_COUNT_FOUR >= parent.getChildCount()) {
                outRect.bottom = 0;
            }
        }
    }
}
