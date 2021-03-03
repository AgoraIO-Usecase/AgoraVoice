package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.agoravoice.Config;
import io.agora.agoravoice.R;
import io.agora.agoravoice.manager.AudioManager;
import io.agora.agoravoice.utils.VoiceUtil;

public class SoundEffectActionSheet extends AbstractActionSheet {
    public interface SoundEffectActionListener {
        void onVoiceBeautySelected(int type);
        void on3DHumanVoiceSelected();
        void onElectronicVoiceParamChanged(int key, int value);
        void onVoiceBeautyUnselected();
    }

    private static final int TITLE_TEXT_DEFAULT = Color.parseColor("#FFababab");
    private static final int GRID_COUNT = 4;

    private static final int TYPE_SPACE = 0;
    private static final int TYPE_CHANGE = 1;
    private static final int TYPE_FLAVOUR = 2;
    private static final int TYPE_ELECTRONIC = 3;
    private static final int TYPE_MAGIC_NOTES = 4;

    private String[] mSoundEffectTypeNames;
    private String[] mSpaceEffectNames;
    private String[] mChangeEffectNames;
    private String[] mStyleEffectNames;
    private String[] mElectronicKeyNames;
    private String[] mElectronicToneNames;

    private int mSelectedType = -1;
    private int mSelected1 = -1;
    private int mSelected2 = -1;
    private int mSelected3 = -1;

    private AppCompatImageView mElectronicSwitch;
    private ElectronicKeyAdapter mKeyAdapter;
    private ElectronicToneAdapter mValueAdapter;
    private int mSelectedKey = 0;
    private int mSelectedValue = 0;

    private RelativeLayout mContentLayout;

    private SoundEffectTypeAdapter mTypeAdapter;

    private Config mConfig;

    private SoundEffectActionListener mListener;

    public SoundEffectActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.action_sheet_sound_effect, this);

        RecyclerView typeRecyclerView = findViewById(R.id.action_sheet_sound_effect_type_recycler);
        typeRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(),
                RecyclerView.HORIZONTAL, false));
        mTypeAdapter = new SoundEffectTypeAdapter();
        typeRecyclerView.setAdapter(mTypeAdapter);

        mContentLayout = findViewById(R.id.action_sheet_sound_effect_content_layout);

        mSoundEffectTypeNames = getResources().getStringArray(R.array.action_sheet_sound_effect_types);
        mSpaceEffectNames = getResources().getStringArray(R.array.action_sheet_sound_effect_space_names);
        mChangeEffectNames = getResources().getStringArray(R.array.action_sheet_sound_effect_change_names);
        mStyleEffectNames = getResources().getStringArray(R.array.action_sheet_sound_effect_style_names);
        mElectronicKeyNames = getResources().getStringArray(R.array.action_sheet_sound_effect_electronic_keys);
        mElectronicToneNames = getResources().getStringArray(R.array.action_sheet_sound_effect_electronic_tones);

        changeType(TYPE_SPACE);
    }

    public void setSoundEffectActionListener(SoundEffectActionListener listener) {
        mListener = listener;
    }

    public void setConfig(@NonNull Config config) {
        mConfig = config;
        mSelectedKey = mConfig.getElectronicVoiceKey();
        mSelectedValue = mConfig.getElectronicVoiceValue();
        changeType(mSelectedType);
    }

    private void changeType(int type) {
        mSelectedType = type;
        mTypeAdapter.notifyDataSetChanged();
        mContentLayout.removeAllViews();

        mSelected1 = -1;
        mSelected2 = -1;
        mSelected3 = -1;

        switch (mSelectedType) {
            case TYPE_SPACE:
                mSelected1 = getSelectedItem();
                initSpaceSoundEffect();
                break;
            case TYPE_CHANGE:
                mSelected2 = getSelectedItem();
                initChangeSoundEffect();
                break;
            case TYPE_FLAVOUR:
                mSelected3 = getSelectedItem();
                initFlavourSoundEffect();
                break;
            case TYPE_ELECTRONIC:
                initElectronicSoundEffect();
                break;
            case TYPE_MAGIC_NOTES:
                initMagicNotesSoundEffect();
                break;
        }
    }

    private int getSelectedItem() {
        int type = mConfig == null ? -1 : mConfig.getCurAudioEffect();
        if (type == -1) return -1;

        switch (mSelectedType) {
            case TYPE_SPACE:
                if (AudioManager.EFFECT_SPACING_KTV <= type &&
                        type <= AudioManager.EFFECT_SPACING_ETHEREAL) {
                    return type - AudioManager.EFFECT_SPACING_KTV;
                } else {
                    return -1;
                }
            case TYPE_CHANGE:
                if (AudioManager.EFFECT_VOICE_CHANGE_UNCLE <= type &&
                        type <= AudioManager.EFFECT_VOICE_CHANGE_HULK) {
                    return type - AudioManager.EFFECT_VOICE_CHANGE_UNCLE;
                } else {
                    return -1;
                }
            case TYPE_FLAVOUR:
                if (AudioManager.EFFECT_FLAVOR_RNB <= type &&
                        type <= AudioManager.EFFECT_FLAVOR_HIP_HOP) {
                    return type - AudioManager.EFFECT_FLAVOR_RNB;
                } else {
                    return -1;
                }
            default: return -1;
        }
    }

    private int getSelectedType(int position) {
        switch (mSelectedType) {
            case TYPE_SPACE:
                return AudioManager.EFFECT_SPACING_KTV + position;
            case TYPE_CHANGE:
                return AudioManager.EFFECT_VOICE_CHANGE_UNCLE + position;
            case TYPE_FLAVOUR:
                return AudioManager.EFFECT_FLAVOR_RNB + position;
            default: return -1;
        }
    }

    private void initSpaceSoundEffect() {
        RecyclerView recyclerView = new RecyclerView(getContext());
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), GRID_COUNT));
        recyclerView.setAdapter(new SpaceEffectAdapter());
        mContentLayout.addView(recyclerView, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    }

    private void initChangeSoundEffect() {
        RecyclerView recyclerView = new RecyclerView(getContext());
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), GRID_COUNT));
        recyclerView.setAdapter(new ChangeEffectAdapter());
        mContentLayout.addView(recyclerView, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    }

    private void initFlavourSoundEffect() {
        RecyclerView recyclerView = new RecyclerView(getContext());
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), GRID_COUNT));
        recyclerView.setAdapter(new StyleEffectAdapter());
        mContentLayout.addView(recyclerView, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    }

    private boolean electronicEnabled() {
        return mConfig != null && AudioManager.EFFECT_ELECTRONIC == mConfig.getCurAudioEffect();
    }

    private void initElectronicSoundEffect() {
        View layout = LayoutInflater.from(getContext()).inflate(
                R.layout.action_sheet_sound_effect_electronic_layout, this, false);
        RecyclerView recyclerView = layout.findViewById(R.id.action_sheet_sound_effect_electronic_key_recycler);
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), GRID_COUNT));
        mKeyAdapter = new ElectronicKeyAdapter();
        recyclerView.setAdapter(mKeyAdapter);
        recyclerView.addItemDecoration(new TextGridItemDecoration());

        recyclerView = layout.findViewById(R.id.action_sheet_sound_effect_electronic_tone_recycler);
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), GRID_COUNT));
        mValueAdapter = new ElectronicToneAdapter();
        recyclerView.setAdapter(mValueAdapter);
        recyclerView.addItemDecoration(new TextGridItemDecoration());
        mContentLayout.addView(layout, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);

        mElectronicSwitch = layout.findViewById(R.id.action_sheet_electronic_switch);
        boolean enabled = electronicEnabled();
        mElectronicSwitch.setActivated(enabled);
        mKeyAdapter.setEnabled(enabled);
        mValueAdapter.setEnabled(enabled);

        mElectronicSwitch.setOnClickListener(view -> {
            if (view.isActivated()) {
                view.setActivated(false);
                mKeyAdapter.setEnabled(false);
                mValueAdapter.setEnabled(false);
                if (mListener != null) {
                    mListener.onVoiceBeautyUnselected();
                }
            } else {
                view.setActivated(true);
                mKeyAdapter.setEnabled(true);
                mValueAdapter.setEnabled(true);

                if (mConfig != null) {
                    mSelectedKey = mConfig.getElectronicVoiceKey();
                    mSelectedValue = mConfig.getElectronicVoiceValue();
                } else {
                    mSelectedKey = 1;
                    mSelectedValue = 1;
                }

                if (mListener != null) {
                    mListener.onVoiceBeautySelected(AudioManager.EFFECT_ELECTRONIC);
                    mListener.onElectronicVoiceParamChanged(mSelectedKey, mSelectedValue);
                }
            }

            if (mConfig != null) {
                mConfig.setElectronicVoiceParam(mSelectedKey, mSelectedValue);
            }

            mKeyAdapter.notifyDataSetChanged();
            mValueAdapter.notifyDataSetChanged();
        });
    }

    private void initMagicNotesSoundEffect() {
        View layout = LayoutInflater.from(getContext()).inflate(
                R.layout.action_sheet_sound_effect_comming_soon, this, false);
        mContentLayout.addView(layout, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    }

    private class SoundEffectTypeAdapter extends RecyclerView.Adapter<SoundEffectTypeViewHolder> {
        @NonNull
        @Override
        public SoundEffectTypeViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new SoundEffectTypeViewHolder(LayoutInflater.from(getContext())
                    .inflate(R.layout.action_sheet_sound_effect_type_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull SoundEffectTypeViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            holder.title.setText(mSoundEffectTypeNames[pos]);

            if (pos == mSelectedType) {
                holder.title.setTextColor(Color.WHITE);
                holder.title.setTypeface(Typeface.DEFAULT_BOLD);
                holder.indicator.setVisibility(VISIBLE);
            } else {
                holder.title.setTypeface(Typeface.DEFAULT);
                holder.title.setTextColor(TITLE_TEXT_DEFAULT);
                holder.indicator.setVisibility(GONE);
            }

            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelectedType) return;
                changeType(pos);
                mSelectedType = pos;
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return mSoundEffectTypeNames.length;
        }
    }

    private static class SoundEffectTypeViewHolder extends RecyclerView.ViewHolder {
        AppCompatTextView title;
        View indicator;

        public SoundEffectTypeViewHolder(@NonNull View itemView) {
            super(itemView);

            title = itemView.findViewById(R.id.action_sheet_sound_effect_type_item_name);
            indicator = itemView.findViewById(R.id.action_sheet_sound_effect_type_item_indicator);
        }
    }

    private class SpaceEffectAdapter extends RecyclerView.Adapter<EffectImageViewHolder> {
        @NonNull
        @Override
        public EffectImageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new EffectImageViewHolder(LayoutInflater.from(getContext())
                    .inflate(R.layout.action_sheet_voice_beauty_item_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull EffectImageViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == mSelected1;
            holder.image.setImageResource(VoiceUtil.SPACE_EFFECT_IMAGE_RES[pos]);
            holder.name.setText(mSpaceEffectNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);

            if (pos == mSpaceEffectNames.length - 1) {
                // Special click handler for 3D voice
                holder.itemView.setActivated(false);
                holder.itemView.setOnClickListener(view -> {
                    if (mListener != null) {
                        mListener.on3DHumanVoiceSelected();
                    }
                });
            } else {
                holder.itemView.setActivated(selected);
                holder.itemView.setOnClickListener(view -> {
                    if (pos == mSelected1) {
                        mSelected1 = -1;
                        if (mListener != null) {
                            mListener.onVoiceBeautyUnselected();
                        }
                    } else {
                        if (mListener != null) {
                            mListener.onVoiceBeautySelected(getSelectedType(pos));
                        }
                        mSelected1 = pos;
                    }
                    notifyDataSetChanged();
                });
            }
        }

        @Override
        public int getItemCount() {
            return mSpaceEffectNames.length;
        }
    }

    private static class EffectImageViewHolder extends RecyclerView.ViewHolder {
        AppCompatImageView image;
        AppCompatTextView name;

        public EffectImageViewHolder(@NonNull View itemView) {
            super(itemView);
            image = itemView.findViewById(R.id.action_sheet_voice_beauty_item_icon);
            name = itemView.findViewById(R.id.action_sheet_voice_beauty_item_name);
        }
    }

    private class ChangeEffectAdapter extends RecyclerView.Adapter<EffectImageViewHolder> {
        @NonNull
        @Override
        public EffectImageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new EffectImageViewHolder(LayoutInflater.from(getContext())
                    .inflate(R.layout.action_sheet_voice_beauty_item_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull EffectImageViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == mSelected2;
            holder.image.setImageResource(VoiceUtil.CHANGE_EFFECT_IMAGE_RES[pos]);
            holder.name.setText(mChangeEffectNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.itemView.setActivated(selected);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected2) {
                    mSelected2 = -1;
                    if (mListener != null) {
                        mListener.onVoiceBeautyUnselected();
                    }
                } else {
                    mSelected2 = pos;
                    if (mListener != null) {
                        mListener.onVoiceBeautySelected(getSelectedType(pos));
                    }
                }
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return mChangeEffectNames.length;
        }
    }

    private class StyleEffectAdapter extends RecyclerView.Adapter<EffectImageViewHolder> {
        @NonNull
        @Override
        public EffectImageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new EffectImageViewHolder(LayoutInflater.from(getContext())
                    .inflate(R.layout.action_sheet_voice_beauty_item_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull EffectImageViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == mSelected3;
            holder.image.setImageResource(VoiceUtil.FLAVOUR_EFFECT_IMAGE_RES[pos]);
            holder.name.setText(mStyleEffectNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.itemView.setActivated(selected);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected3) {
                    mSelected3 = -1;
                    if (mListener != null) {
                        mListener.onVoiceBeautyUnselected();
                    }
                } else {
                    mSelected3 = pos;
                    if (mListener != null) {
                        mListener.onVoiceBeautySelected(getSelectedType(pos));
                    }
                }
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return mStyleEffectNames.length;
        }
    }

    private class ElectronicKeyAdapter extends RecyclerView.Adapter<ElectronicKeyViewHolder> {
        private boolean mEnabled;

        void setEnabled(boolean enabled) {
            mEnabled = enabled;
        }

        @NonNull
        @Override
        public ElectronicKeyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new ElectronicKeyViewHolder(LayoutInflater.from(getContext()).inflate(
                    R.layout.action_sheet_voice_beauty_item_text_only_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull ElectronicKeyViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == (mSelectedKey - 1);
            holder.name.setText(mElectronicKeyNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.layout.setActivated(selected);
            holder.layout.setEnabled(mEnabled);
            if (!mEnabled) return;
            holder.itemView.setOnClickListener(view -> {
                if (pos != mSelectedKey - 1) {
                    mSelectedKey = pos + 1;
                    if (mListener != null) {
                        mListener.onElectronicVoiceParamChanged(mSelectedKey, mSelectedValue);
                    }
                }
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return mElectronicKeyNames.length;
        }
    }

    private static class ElectronicKeyViewHolder extends RecyclerView.ViewHolder {
        RelativeLayout layout;
        AppCompatTextView name;

        public ElectronicKeyViewHolder(@NonNull View itemView) {
            super(itemView);
            layout = itemView.findViewById(R.id.action_sheet_voice_beauty_text_item_layout);
            name = itemView.findViewById(R.id.action_sheet_voice_beauty_text_item_view);
        }
    }

    private class ElectronicToneAdapter extends RecyclerView.Adapter<ElectronicToneViewHolder> {
        private boolean mEnabled;

        void setEnabled(boolean enabled) {
            mEnabled = enabled;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public ElectronicToneViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new ElectronicToneViewHolder(LayoutInflater.from(getContext()).inflate(
                    R.layout.action_sheet_voice_beauty_item_text_only_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull ElectronicToneViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == (mSelectedValue - 1);
            holder.name.setText(mElectronicToneNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.layout.setActivated(selected);
            holder.layout.setEnabled(mEnabled);
            if (!mEnabled) return;
            holder.itemView.setOnClickListener(view -> {
                if (pos != mSelectedValue - 1) {
                    mSelectedValue = pos + 1;
                    if (mListener != null && electronicEnabled()) {
                        mListener.onElectronicVoiceParamChanged(mSelectedKey, mSelectedValue);
                    }
                }
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return mElectronicToneNames.length;
        }
    }

    private static class ElectronicToneViewHolder extends RecyclerView.ViewHolder {
        RelativeLayout layout;
        AppCompatTextView name;

        public ElectronicToneViewHolder(@NonNull View itemView) {
            super(itemView);
            layout = itemView.findViewById(R.id.action_sheet_voice_beauty_text_item_layout);
            name = itemView.findViewById(R.id.action_sheet_voice_beauty_text_item_view);
        }
    }

    private class TextGridItemDecoration extends RecyclerView.ItemDecoration {
        private int mMargin = getResources().getDimensionPixelOffset(R.dimen.margin_2);

        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                                   @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            int pos = parent.getChildAdapterPosition(view);
            outRect.set(mMargin, mMargin, mMargin, mMargin);
            if (pos < GRID_COUNT) {
                outRect.top = 0;
            } else if (pos + GRID_COUNT >= parent.getChildCount()) {
                outRect.bottom = 0;
            }

            if (pos % GRID_COUNT == 0) {
                outRect.left = 0;
            } else if (pos % GRID_COUNT + 1 == GRID_COUNT) {
                outRect.right = 0;
            }
        }
    }
}
