package io.agora.agoravoice.ui.views.actionsheets;

import android.content.Context;
import android.widget.RelativeLayout;

import io.agora.agoravoice.AgoraApplication;

public abstract class AbstractActionSheet extends RelativeLayout {
    public AbstractActionSheet(Context context) {
        super(context);
    }

    protected AgoraApplication application() {
        return (AgoraApplication) getContext().getApplicationContext();
    }
}
