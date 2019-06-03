package net.nend.reactmodule;

import android.app.Activity;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import net.nend.android.NendAdInterstitial;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static net.nend.android.NendAdInterstitial.NendAdInterstitialClickType;
import static net.nend.android.NendAdInterstitial.NendAdInterstitialShowResult;

public class NendInterstitialAdModule extends ReactContextBaseJavaModule implements NendAdInterstitial.OnCompletionListenerSpot {

    private static final String REACT_CLASS = "NendInterstitialAd";
    private static final String EVENT_TYPE_CLOSE = "onInterstitialAdClosed";

    private Map<String, List<Promise>> loadPromises = new HashMap<>();

    public NendInterstitialAdModule(ReactApplicationContext reactContext) {
        super(reactContext);
        NendAdInterstitial.setListener(this);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactMethod
    public void loadAd(final String spotId, final String apiKey, final Promise promise) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (loadPromises.containsKey(spotId)) {
                    loadPromises.get(spotId).add(promise);
                    return;
                }
                final List<Promise> promises = new ArrayList<>();
                promises.add(promise);
                loadPromises.put(spotId, promises);
                try {
                    NendAdInterstitial.loadAd(getReactApplicationContext(), apiKey, Integer.valueOf(spotId));
                } catch (NumberFormatException ignore) {

                }
            }
        });
    }

    @ReactMethod
    public void show(final String spotId, final Promise promise) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final Activity activity = getCurrentActivity();
                if (activity != null) {
                    NendAdInterstitialShowResult result = NendAdInterstitial.showAd(
                            activity,
                            Integer.valueOf(spotId),
                            new NendAdInterstitial.OnClickListener() {
                                @Override
                                public void onClick(NendAdInterstitialClickType clickType) {
                                    sendEvent(EVENT_TYPE_CLOSE, spotId, clickType);
                                }
                            });
                    if (result == NendAdInterstitialShowResult.AD_SHOW_SUCCESS) {
                        promise.resolve(null);
                    } else {
                        promise.reject(new Exception(result.name()));
                    }
                } else {
                    promise.reject(new Exception("AD_CANNOT_DISPLAY"));
                }
            }
        });
    }

    @ReactMethod
    public void setAutoReloadEnabled(boolean enabled) {
        NendAdInterstitial.isAutoReloadEnabled = enabled;
    }

    @Override
    public void onCompletion(NendAdInterstitial.NendAdInterstitialStatusCode statusCode, int spotId) {
        String completedSpotId = String.valueOf(spotId);
        final List<Promise> promises = loadPromises.remove(completedSpotId);
        if (promises != null) {
            for (Promise promise : promises) {
                if (statusCode == NendAdInterstitial.NendAdInterstitialStatusCode.SUCCESS) {
                    promise.resolve(null);
                } else {
                    promise.reject(new Exception(statusCode.name()));
                }
            }
        }
    }

    @Override
    public void onCompletion(NendAdInterstitial.NendAdInterstitialStatusCode statusCode) {
        // nop
    }

    private void sendEvent(String eventType, String spotId, NendAdInterstitialClickType type) {
        final WritableMap params = Arguments.createMap();
        params.putString("spotId", spotId);
        params.putString("clickType", type.name());
        getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventType, params);
    }

}
