package net.nend.reactmodule;

import android.app.Activity;
import android.util.SparseArray;
import android.view.View;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import net.nend.android.NendAdNativeVideo;
import net.nend.android.NendAdNativeVideoListener;
import net.nend.android.NendAdNativeVideoLoader;
import net.nend.android.NendAdUserFeature;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.WeakHashMap;
import java.util.concurrent.atomic.AtomicInteger;

import javax.annotation.Nullable;

@ReactModule(name = NendVideoNativeAdModule.NAME)
public class NendVideoNativeAdModule extends ReactContextBaseJavaModule implements NendAdNativeVideoListener {
    public static final String NAME = "NendVideoNativeAd";

    private static final String REACT_CLASS = NAME;
    private final Map<String, NendAdNativeVideoLoader> loaderCache = new HashMap<>();
    private final SparseArray<NendAdNativeVideo> videoNativeAdCache = new SparseArray<>();
    private final WeakHashMap<NendAdNativeVideo, Integer> videoNativeAdToReferenceId = new WeakHashMap<>();
    private final AtomicInteger videoNativeAdReferenceId = new AtomicInteger(0);

    public NendVideoNativeAdModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        Map<String, Object> map = new HashMap<>();
        map.put("FullScreen", NendAdNativeVideo.VideoClickOption.FullScreen.ordinal());
        map.put("LP", NendAdNativeVideo.VideoClickOption.LP.ordinal());
        return map;
    }

    @ReactMethod
    public void initialize(final String spotId, final String apiKey, final int clickOption) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!loaderCache.containsKey(spotId)) {
                    NendAdNativeVideoLoader loader = new NendAdNativeVideoLoader(
                            getReactApplicationContext(),
                            Integer.valueOf(spotId),
                            apiKey,
                            clickOption == 0 ? NendAdNativeVideo.VideoClickOption.FullScreen : NendAdNativeVideo.VideoClickOption.LP);
                    loaderCache.put(spotId, loader);
                }
            }
        });
    }

    @ReactMethod
    public void loadAd(final String spotId, final Promise promise) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final NendAdNativeVideoLoader loader = loaderCache.get(spotId);
                if (loader != null) {
                    loader.loadAd(new NendAdNativeVideoLoader.Callback() {
                        @Override
                        public void onSuccess(NendAdNativeVideo nendAdNativeVideo) {
                            final int refId = videoNativeAdReferenceId.incrementAndGet();
                            videoNativeAdCache.put(refId, nendAdNativeVideo);
                            videoNativeAdToReferenceId.put(nendAdNativeVideo, refId);
                            nendAdNativeVideo.setListener(NendVideoNativeAdModule.this);
                            promise.resolve(convertMap(nendAdNativeVideo, refId));
                        }

                        @Override
                        public void onFailure(int i) {
                            promise.reject(new Exception("Error: " + i));
                        }
                    });
                }
            }
        });
    }

    @ReactMethod
    public void registerClickableViews(final int refId, final ReadableArray tags) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final NendAdNativeVideo videoAd = videoNativeAdCache.get(refId);
                final Activity activity = getCurrentActivity();
                ArrayList<View> views = new ArrayList<>();
                if (videoAd != null && activity != null) {
                    final int size = tags.size();
                    for (int i = 0; i < size; i++) {
                        View view = activity.findViewById(tags.getInt(i));
                        if (view != null) {
                            views.add(view);
                        }
                    }
                    if (!views.isEmpty()) {
                        videoAd.registerInteractionViews(views);
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
                final NendAdNativeVideoLoader loader = loaderCache.get(spotId);
                if (loader != null) {
                    loader.setUserId(userId);
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
                final NendAdNativeVideoLoader loader = loaderCache.get(spotId);
                if (module != null && loader != null) {
                    NendAdUserFeature.Builder builder = module.getBuilder(refId);
                    if (builder != null) {
                        loader.setUserFeature(builder.build());
                    }
                }
            }
        });
    }

    @ReactMethod
    public void destroyLoader(final String spotId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NendAdNativeVideoLoader loader = loaderCache.remove(spotId);
                if (loader != null) {
                    loader.releaseLoader();
                }
            }
        });
    }

    @ReactMethod
    public void destroyAd(final int refId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NendAdNativeVideo videoAd = videoNativeAdCache.get(refId);
                if (videoAd != null) {
                    videoAd.deactivate();
                    videoNativeAdCache.remove(refId);
                }
            }
        });
    }

    NendAdNativeVideo getVideoNativeAdCache(int refId) {
        return videoNativeAdCache.get(refId);
    }

    private WritableMap convertMap(NendAdNativeVideo videoNativeAd, int refId) {
        WritableMap map = Arguments.createMap();
        map.putInt("referenceId", refId);
        map.putString("logoImageUrl", videoNativeAd.getLogoImageUrl());
        map.putString("title", videoNativeAd.getTitleText());
        map.putString("description", videoNativeAd.getDescriptionText());
        map.putString("advertiserName", videoNativeAd.getAdvertiserName());
        map.putDouble("userRating", videoNativeAd.getUserRating());
        map.putInt("userRatingCount", videoNativeAd.getUserRatingCount());
        map.putString("callToAction", videoNativeAd.getCallToActionText());
        return map;
    }

    private void sendEvent(NendAdNativeVideo videoAd, String eventType) {
        if (videoNativeAdToReferenceId.containsKey(videoAd)) {
            WritableMap params = Arguments.createMap();
            params.putInt("refId", videoNativeAdToReferenceId.get(videoAd));
            params.putString("eventType", eventType);
            getReactApplicationContext()
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit("VideoNativeAdEventListener", params);
        }
    }

    @Override
    public void onImpression(NendAdNativeVideo nendAdNativeVideo) {
        sendEvent(nendAdNativeVideo, "onImpression");
    }

    @Override
    public void onClickAd(NendAdNativeVideo nendAdNativeVideo) {
        sendEvent(nendAdNativeVideo, "onClickAd");
    }

    @Override
    public void onClickInformation(NendAdNativeVideo nendAdNativeVideo) {
        sendEvent(nendAdNativeVideo, "onClickInformation");
    }

}
