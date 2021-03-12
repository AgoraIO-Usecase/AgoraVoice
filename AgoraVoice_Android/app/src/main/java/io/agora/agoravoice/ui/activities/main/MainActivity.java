package io.agora.agoravoice.ui.activities.main;

import android.os.Bundle;

import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.ui.NavigationUI;

import com.google.android.material.bottomnavigation.BottomNavigationView;

import io.agora.agoravoice.R;
import io.agora.agoravoice.ui.activities.BaseActivity;
import io.agora.agoravoice.utils.WindowUtil;

public class MainActivity extends BaseActivity {
    private static final String TAG = MainActivity.class.getSimpleName();

    private BottomNavigationView mNavView;
    private NavController mNavController;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WindowUtil.hideStatusBar(getWindow(), false);
        setContentView(R.layout.activity_main);
        initUI();
    }

    private void initUI() {
        initNavigation();
    }

    private void initNavigation() {
        mNavController = Navigation.findNavController(this, R.id.nav_host_fragment);

        mNavView = findViewById(R.id.nav_view);
        mNavView.setItemIconTintList(null);
        // changeItemHeight(mNavView);
        mNavView.setOnNavigationItemSelectedListener(item -> {
            int selectedId = item.getItemId();
            int currentId = mNavController.getCurrentDestination() == null ?
                    0 : mNavController.getCurrentDestination().getId();

            // Do not respond to this click event because
            // we do not want to refresh this fragment
            // by repeatedly selecting the same menu item.
            if (selectedId == currentId) return false;
            NavigationUI.onNavDestinationSelected(item, mNavController);
            return true;
        });
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        proxy().logout();
    }
}
