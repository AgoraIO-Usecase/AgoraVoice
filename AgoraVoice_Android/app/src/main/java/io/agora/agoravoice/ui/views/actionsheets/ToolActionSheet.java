package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatImageView;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.HashMap;
import java.util.Map;

import io.agora.agoravoice.Config;
import io.agora.agoravoice.R;
import io.agora.agoravoice.utils.Const;

public class ToolActionSheet extends AbstractActionSheet {
    private static final int GRID_COUNT = 4;

    private Const.Role mCurrentRole = Const.Role.audience;
    private Map<Const.Role, ToolAdapterConfig> mUIConfig;
    private ToolActionAdapter mAdapter;
    private ToolActionListener mListener;
    private Config mAppConfig;

    public interface ToolActionListener {
        void onToolItemClicked(Const.Role role, View view, int index);
    }

    public ToolActionSheet(Context context) {
        super(context);
        init();
    }

    private void init() {
        mUIConfig = initConfig();

        LayoutInflater.from(getContext()).inflate(R.layout.action_sheet_tool, this);
        RecyclerView recyclerView = findViewById(R.id.action_sheet_tool_recycler);
        recyclerView.setLayoutManager(new GridLayoutManager(getContext(), GRID_COUNT));
        mAdapter = new ToolActionAdapter();
        recyclerView.setAdapter(mAdapter);
    }

    public void setRole(Const.Role role) {
        if (role == mCurrentRole) return;
        mCurrentRole = role;
        mAdapter.notifyDataSetChanged();
    }

    public void setAppConfig(Config config) {
        mAppConfig = config;
    }

    private class ToolActionAdapter extends RecyclerView.Adapter<ToolActionViewHolder> {
        @NonNull
        @Override
        public ToolActionViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new ToolActionViewHolder(LayoutInflater.from(getContext())
                    .inflate(R.layout.action_sheet_tool_item, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull ToolActionViewHolder holder, int position) {
            int pos = holder.getAdapterPosition();
            if (pos < 0 || pos >= getItemCount()) return;
            ToolAdapterConfig config = getCurrentConfigOfRole();
            if (config == null) return;

            holder.icon.setImageResource(config.iconRes[pos]);
            holder.name.setText(config.names[pos]);
            holder.itemView.setOnClickListener(view -> {
                if (mListener != null) mListener.onToolItemClicked(mCurrentRole, holder.itemView, pos);
            });

            // Initialize in-ear monitoring button state
            if (mCurrentRole == Const.Role.owner ||
                mCurrentRole == Const.Role.host) {
                if (config.iconRes[pos] == R.drawable.action_sheet_tool_monitor) {
                    holder.icon.setActivated(mAppConfig != null && mAppConfig.getInEarMonitoring());
                }
            }
        }

        @Override
        public int getItemCount() {
            ToolAdapterConfig config = getCurrentConfigOfRole();
            return config == null ? 0 : config.count;
        }
    }

    private ToolAdapterConfig getCurrentConfigOfRole() {
        return mUIConfig == null ? null : mUIConfig.get(mCurrentRole);
    }

    private static class ToolActionViewHolder extends RecyclerView.ViewHolder {
        AppCompatImageView icon;
        AppCompatTextView name;

        public ToolActionViewHolder(@NonNull View itemView) {
            super(itemView);
            icon = itemView.findViewById(R.id.action_sheet_tool_item_icon);
            name = itemView.findViewById(R.id.action_sheet_tool_item_name);
        }
    }

    private static class ToolAdapterConfig {
        int count;
        int[] iconRes;
        String[] names;

        public ToolAdapterConfig(int count, int[] iconRes, String[] names) {
            this.count = count;
            this.iconRes = iconRes;
            this.names = names;
        }
    }

    private Map<Const.Role, ToolAdapterConfig> initConfig() {
        Map<Const.Role, ToolAdapterConfig> config = new HashMap<>();

        int[] iconAudience = { R.drawable.icon_data };
        String[] namesAudience = getResources().getStringArray(R.array.action_sheet_tool_audience);
        ToolAdapterConfig configAudience = new ToolAdapterConfig(1, iconAudience, namesAudience);
        config.put(Const.Role.audience, configAudience);

        int[] iconHost = { R.drawable.action_sheet_tool_monitor, R.drawable.icon_data };
        String[] namesHost = getResources().getStringArray(R.array.action_sheet_tool_host);
        ToolAdapterConfig configHost = new ToolAdapterConfig(2, iconHost, namesHost);
        config.put(Const.Role.host, configHost);

        int[] iconOwner = {
                R.drawable.action_sheet_tool_monitor,
                R.drawable.icon_music,
                R.drawable.icon_tool_background,
                R.drawable.icon_data
        };

        String[] namesOwner = getResources().getStringArray(R.array.action_sheet_tool_owner);
        ToolAdapterConfig configOwner = new ToolAdapterConfig(4, iconOwner, namesOwner);
        config.put(Const.Role.owner, configOwner);

        return config;
    }

    public void setToolActionListener(ToolActionListener listener) {
        mListener = listener;
    }

    public void refreshUIState() {
        mAdapter.notifyDataSetChanged();
    }
}
