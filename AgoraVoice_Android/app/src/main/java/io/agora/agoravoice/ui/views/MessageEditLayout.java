package io.agora.agoravoice.ui.views;

import android.content.Context;
import android.text.Editable;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.inputmethod.EditorInfo;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.widget.AppCompatEditText;

import io.agora.agoravoice.R;

public class MessageEditLayout extends RelativeLayout implements TextView.OnEditorActionListener {
    private AppCompatEditText mEditText;
    private MessageEditListener mListener;

    public interface MessageEditListener {
        void onMessageSent(String message);
    }

    public MessageEditLayout(Context context) {
        super(context);
        init();
    }

    public MessageEditLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(
                R.layout.message_edit_layout, this, true);
        mEditText = findViewById(R.id.message_edit);
    }

    public void setEditClicked() {
        mEditText.requestFocus();
        mEditText.setSingleLine();
        mEditText.setImeOptions(EditorInfo.IME_ACTION_DONE);
        mEditText.setOnEditorActionListener(this);
    }

    public AppCompatEditText editText() {
        return mEditText;
    }

    @Override
    public boolean onEditorAction(TextView textView, int actionId, KeyEvent keyEvent) {
        if (actionId == EditorInfo.IME_ACTION_DONE) {
            Editable editable = mEditText.getText();
            mEditText.setText("");
            if (mListener != null) {
                mListener.onMessageSent(editable == null ? "" : editable.toString());
            }
            return true;
        }
        return false;
    }

    public void setMessageEditListener(MessageEditListener listener) {
        mListener = listener;
    }
}
