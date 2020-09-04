package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.graphics.Color;
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

import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.VoiceUtil;

public class SoundEffectActionSheet extends AbstractActionSheet {
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
    private String[] mFlavourEffectNames;
    private String[] mElectronicKeyNames;
    private String[] mElectronicToneNames;

    private int mSelectedType = -1;
    private int mSelected1 = -1;
    private int mSelected2 = -1;
    private int mSelected3 = -1;
    private int mSelected4 = -1;

    private RelativeLayout mContentLayout;

    private SoundEffectTypeAdapter mTypeAdapter;

    public SoundEffectActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.action_sheet_souce_effect, this);

        RecyclerView typeRecyclerView = findViewById(R.id.action_sheet_sound_effect_type_recycler);
        typeRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(),
                RecyclerView.HORIZONTAL, false));
        mTypeAdapter = new SoundEffectTypeAdapter();
        typeRecyclerView.setAdapter(mTypeAdapter);

        mContentLayout = findViewById(R.id.action_sheet_sound_effect_content_layout);

        mSoundEffectTypeNames = getResources().getStringArray(R.array.action_sheet_sound_effect_types);
        mSpaceEffectNames = getResources().getStringArray(R.array.action_sheet_sound_effect_space_names);
        mChangeEffectNames = getResources().getStringArray(R.array.action_sheet_sound_effect_change_names);
        mFlavourEffectNames = getResources().getStringArray(R.array.action_sheet_sound_effect_flavour_names);
        mElectronicKeyNames = getResources().getStringArray(R.array.action_sheet_sound_effect_electronic_keys);
        mElectronicToneNames = getResources().getStringArray(R.array.action_sheet_sound_effect_electronic_tones);

        changeType(TYPE_SPACE);
    }

    private void changeType(int type) {
        if (mSelectedType == type) return;
        mSelectedType = type;
        mTypeAdapter.notifyDataSetChanged();
        mContentLayout.removeAllViews();

        switch (mSelectedType) {
            case TYPE_SPACE:
                initSpaceSoundEffect();
                break;
            case TYPE_CHANGE:
                initChangeSoundEffect();
                break;
            case TYPE_FLAVOUR:
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
        recyclerView.setAdapter(new FlavourEffectAdapter());
        mContentLayout.addView(recyclerView, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    }

    private void initElectronicSoundEffect() {
        View layout = LayoutInflater.from(getContext()).inflate(
                R.layout.action_sheet_sound_effect_electronic_layout, this, false);
        RecyclerView recyclerView = layout.findViewById(R.id.action_sheet_sound_effect_electronic_key_recycler);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext(), RecyclerView.HORIZONTAL, false));
        recyclerView.setAdapter(new ElectronicKeyAdapter());

        recyclerView = layout.findViewById(R.id.action_sheet_sound_effect_electronic_tone_recycler);
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), GRID_COUNT));
        recyclerView.setAdapter(new ElectronicToneAdapter());
        mContentLayout.addView(layout, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    }

    private void initMagicNotesSoundEffect() {

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
            holder.itemView.setActivated(selected);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected1) {
                    mSelected1 = -1;
                } else {
                    mSelected1 = pos;
                }
                notifyDataSetChanged();
            });
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
                } else {
                    mSelected2 = pos;
                }
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return mChangeEffectNames.length;
        }
    }

    private class FlavourEffectAdapter extends RecyclerView.Adapter<EffectImageViewHolder> {
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
            holder.name.setText(mFlavourEffectNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.itemView.setActivated(selected);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected3) {
                    mSelected3 = -1;
                } else {
                    mSelected3 = pos;
                }
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return mFlavourEffectNames.length;
        }
    }

    private class ElectronicKeyAdapter extends RecyclerView.Adapter<ElectronicKeyViewHolder> {
        @NonNull
        @Override
        public ElectronicKeyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new ElectronicKeyViewHolder(LayoutInflater.from(getContext()).inflate(
                    R.layout.action_sheet_voice_beauty_item_text_only_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull ElectronicKeyViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == mSelected3;
            holder.name.setText(mElectronicKeyNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.layout.setActivated(selected);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected3) {
                    mSelected3 = -1;
                } else {
                    mSelected3 = pos;
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
        @NonNull
        @Override
        public ElectronicToneViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new ElectronicToneViewHolder(LayoutInflater.from(getContext()).inflate(
                    R.layout.action_sheet_voice_beauty_item_text_only_layout, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull ElectronicToneViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            boolean selected = pos == mSelected3;
            holder.name.setText(mElectronicToneNames[pos]);
            holder.name.setTextColor(selected ? Color.WHITE : TITLE_TEXT_DEFAULT);
            holder.layout.setActivated(selected);
            holder.itemView.setOnClickListener(view -> {
                if (pos == mSelected3) {
                    mSelected3 = -1;
                } else {
                    mSelected3 = pos;
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
}
