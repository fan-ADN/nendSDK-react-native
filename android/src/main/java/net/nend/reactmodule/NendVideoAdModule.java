package net.nend.reactmodule;

import android.app.Activity;
import androidx.annotation.NonNull;
import android.text.TextUtils;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import net.nend.android.NendAdRewardItem;
import net.nend.android.NendAdRewardedListener;
import net.nend.android.NendAdUserFeature;
import net.nend.android.NendAdVideo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

import javax.annotation.Nullable;

abstract class NendVideoAdModule<V extends NendAdVideo> extends ReactContextBaseJavaModule implements NendAdRewardedListener {

    private final Map<String, V> instanceCache = new HashMap<>();
    private final WeakHashMap<NendAdVideo, String> instanceToSpotId = new WeakHashMap<>();
    private final Map<String, List<Promise>> loadPromises = new HashMap<>();

    NendVideoAdModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @NonNull
    abstract V createInstance(Activity activity, int spotId, String apiKey);

    @NonNull
    abstract String getEventName();

    @ReactMethod
    public void initialize(final String spotId, final String apiKey) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!instanceCache.containsKey(spotId)) {
                    final Activity activity = getCurrentActivity();
                    if (activity != null) {
                        try {
                            V videoAd = createInstance(activity, Integer.valueOf(spotId), apiKey);
                            instanceCache.put(spotId, videoAd);
                            instanceToSpotId.put(videoAd, spotId);
                        } catch (NumberFormatException ignore) {
                        }
                    }
                }
            }
        });
    }

    @ReactMethod
    public void setUserId(final String spotId, final String userId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final V videoAd = instanceCache.get(spotId);
                if (videoAd != null) {
                    videoAd.setUserId(userId);
                }
            }
        });
    }

    @ReactMethod
    public void setUserFeature(final String spotId, final int refId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final NendUserFeatureModule module =
                        getReactApplicationContext().getNativeModule(NendUserFeatureModule.class);
                final V videoAd = instanceCache.get(spotId);
                if (module != null && videoAd != null) {
                    NendAdUserFeature.Builder builder = module.getBuilder(refId);
                    if (builder != null) {
                        videoAd.setUserFeature(builder.build());
                    }
                }
            }
        });
    }

    @ReactMethod
    public void loadAd(final String spotId, final Promise promise) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final V videoAd = instanceCache.get(spotId);
                if (videoAd != null) {
                    if (loadPromises.containsKey(spotId)) {
                        loadPromises.get(spotId).add(promise);
                        return;
                    }

                    List<Promise> list = new ArrayList<>();
                    list.add(promise);
                    loadPromises.put(spotId, list);
                    videoAd.loadAd();
                }
            }
        });
    }

    @ReactMethod
    public void show(final String spotId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final V videoAd = instanceCache.get(spotId);
                final Activity activity = getCurrentActivity();
                if (videoAd != null && activity != null) {
                    videoAd.showAd(activity);
                }
            }
        });
    }

    @ReactMethod
    public void isLoaded(final String spotId, final Promise promise) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final V videoAd = instanceCache.get(spotId);
                boolean ret = videoAd != null && videoAd.isLoaded();
                promise.resolve(ret);
            }
        });
    }

    @ReactMethod
    public void destroy(final String spotId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final V videoAd = instanceCache.remove(spotId);
                if (videoAd != null) {
                    videoAd.releaseAd();
                }
                loadPromises.remove(spotId);
            }
        });
    }

    @Override
    public void onRewarded(NendAdVideo nendAdVideo, NendAdRewardItem nendAdRewardItem) {
        final WritableMap map = Arguments.createMap();
        map.putString("rewardName", nendAdRewardItem.getCurrencyName());
        map.putInt("rewardAmount", nendAdRewardItem.getCurrencyAmount());
        sendEvent(instanceToSpotId.get(nendAdVideo), "onRewarded", map);
    }

    @Override
    public void onLoaded(NendAdVideo nendAdVideo) {
        final String spotId = instanceToSpotId.get(nendAdVideo);
        if (spotId != null) {
            List<Promise> promises = loadPromises.remove(spotId);
            if (promises != null) {
                for (Promise promise : promises) {
                    promise.resolve(null);
                }
            }
        }
    }

    @Override
    public void onFailedToLoad(NendAdVideo nendAdVideo, int i) {
        final String spotId = instanceToSpotId.get(nendAdVideo);
        if (spotId != null) {
            List<Promise> promises = loadPromises.remove(spotId);
            if (promises != null) {
                for (Promise promise : promises) {
                    promise.reject(String.valueOf(i), spotId);
                }
            }
        }
    }

    @Override
    public void onFailedToPlay(NendAdVideo nendAdVideo) {
        sendEvent(instanceToSpotId.get(nendAdVideo), "onVideoPlaybackError", null);
    }

    @Override
    public void onShown(NendAdVideo nendAdVideo) {
        sendEvent(instanceToSpotId.get(nendAdVideo), "onVideoShown", null);
    }

    @Override
    public void onClosed(NendAdVideo nendAdVideo) {
        sendEvent(instanceToSpotId.get(nendAdVideo), "onVideoClosed", null);
    }

    @Override
    public void onStarted(NendAdVideo nendAdVideo) {
        sendEvent(instanceToSpotId.get(nendAdVideo), "onVideoPlaybackStarted", null);
    }

    @Override
    public void onStopped(NendAdVideo nendAdVideo) {
        sendEvent(instanceToSpotId.get(nendAdVideo), "onVideoPlaybackStopped", null);
    }

    @Override
    public void onCompleted(NendAdVideo nendAdVideo) {
        sendEvent(instanceToSpotId.get(nendAdVideo), "onVideoPlaybackCompleted", null);
    }

    @Override
    public void onAdClicked(NendAdVideo nendAdVideo) {
        sendEvent(instanceToSpotId.get(nendAdVideo), "onVideoAdClicked", null);
    }

    @Override
    public void onInformationClicked(NendAdVideo nendAdVideo) {
        sendEvent(instanceToSpotId.get(nendAdVideo), "onVideoAdInformationClicked", null);
    }

    V getInstance(String spotId) {
        return instanceCache.get(spotId);
    }

    private void sendEvent(String spotId, String eventType, @Nullable WritableMap params) {
        if (TextUtils.isEmpty(spotId)) {
            return;
        }
        if (params == null) {
            params = Arguments.createMap();
        }
        params.putString("spotId", spotId);
        params.putString("eventType", eventType);
        getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(getEventName(), params);
    }

}
