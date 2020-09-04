package io.agora.agoravoice.ui.activities.main;

import android.os.Bundle;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.ui.NavigationUI;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.bottomnavigation.BottomNavigationMenuView;
import com.google.android.material.bottomnavigation.BottomNavigationView;

import java.lang.reflect.Field;

import io.agora.agoravoice.R;
import io.agora.agoravoice.ui.activities.BaseActivity;
import io.agora.agoravoice.utils.WindowUtil;

public class MainActivity extends BaseActivity {
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
            // WindowUtil.hideStatusBar(getWindow(), true);
            return true;
        });
    }

//    private void changeItemHeight(@NonNull BottomNavigationView navView) {
//        // Bottom navigation menu uses a hardcode menu item
//        // height which cannot be changed by a layout attribute.
//        // Change the item height using reflection for
//        // a comfortable padding between icon and label.
//        int itemHeight = getResources().getDimensionPixelSize(R.dimen.nav_bar_height);
//        BottomNavigationMenuView menu =
//                (BottomNavigationMenuView) navView.getChildAt(0);
//        try {
//            Field itemHeightField = BottomNavigationMenuView.class.getDeclaredField("itemHeight");
//            itemHeightField.setAccessible(true);
//            itemHeightField.set(menu, itemHeight);
//        } catch (NoSuchFieldException | IllegalAccessException e) {
//            e.printStackTrace();
//        }
//    }
}
