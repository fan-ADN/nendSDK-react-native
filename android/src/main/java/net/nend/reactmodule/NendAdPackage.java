package net.nend.reactmodule;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.Arrays;
import java.util.List;

public class NendAdPackage implements ReactPackage {

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        return Arrays.<NativeModule>asList(
                new NendRewardedVideoAdModule(reactContext),
                new NendInterstitialVideoAdModule(reactContext),
                new NendInterstitialAdModule(reactContext),
                new NendNativeAdModule(reactContext),
                new NendUserFeatureModule(reactContext));
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Arrays.<ViewManager>asList(new NendAdViewManager());
    }

}
