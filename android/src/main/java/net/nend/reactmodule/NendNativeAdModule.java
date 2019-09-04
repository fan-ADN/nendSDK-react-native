package net.nend.reactmodule;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.SparseArray;
import android.view.View;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.views.text.ReactTextView;

import net.nend.android.NendAdNative;
import net.nend.android.NendAdNativeClient;
import net.nend.android.internal.connectors.NendNativeAdConnector;
import net.nend.android.internal.connectors.NendNativeAdConnectorFactory;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import static net.nend.android.NendAdNative.AdvertisingExplicitly;

public class NendNativeAdModule extends ReactContextBaseJavaModule {

    private static final String REACT_CLASS = "NendNativeAd";
    private static final Map<String, AdvertisingExplicitly> AD_EXPLICITLY_MAP = new HashMap<String, AdvertisingExplicitly>() {
        {
            put("PR", AdvertisingExplicitly.PR);
            put("Sponsored", AdvertisingExplicitly.SPONSORED);
            put("AD", AdvertisingExplicitly.AD);
            put("Promotion", AdvertisingExplicitly.PROMOTION);
        }
    };
    private final Map<String, NendAdNativeClient> clientCache = new HashMap<>();
    private final SparseArray<NendAdNative> nativeAdCache = new SparseArray<>();
    private final AtomicInteger nativeAdReferenceId = new AtomicInteger(0);

    public NendNativeAdModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactMethod
    public void loadAd(final String spotId, final String apiKey, final String adExplicitly, final Promise promise) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final int id = Integer.valueOf(spotId);
                NendAdNativeClient client = clientCache.get(id);
                if (client == null) {
                    client = new NendAdNativeClient(getReactApplicationContext(), id, apiKey);
                    clientCache.put(spotId, client);
                }
                client.loadAd(new NendAdNativeClient.Callback() {
                    @Override
                    public void onSuccess(NendAdNative nendAdNative) {
                        final int ref = nativeAdReferenceId.incrementAndGet();
                        nativeAdCache.put(ref, nendAdNative);
                        promise.resolve(convertMap(nendAdNative, ref, AD_EXPLICITLY_MAP.get(adExplicitly)));
                    }

                    @Override
                    public void onFailure(NendAdNativeClient.NendError nendError) {
                        promise.reject(new Exception(nendError.getCode() + ": " + nendError.getMessage()));
                    }
                });
            }
        });
    }

    @ReactMethod
    public void activate(final int refId, final int adViewTag, final int prViewTag) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final Activity activity = getCurrentActivity();
                final NendAdNative nativeAd = nativeAdCache.get(refId);
                if (activity != null && nativeAd != null) {
                    View adView = activity.findViewById(adViewTag);
                    View prView = activity.findViewById(prViewTag);
                    if (adView != null && prView != null) {
                        nativeAd.activate(adView, (ReactTextView) prView);
                    }
                }
            }
        });
    }

    @ReactMethod
    public void performAdClick(final int refId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final Activity activity = getCurrentActivity();
                final NendAdNative nativeAd = nativeAdCache.get(refId);
                if (activity != null && nativeAd != null) {
                    final NendNativeAdConnector connector = NendNativeAdConnectorFactory.createNativeAdConnector(nativeAd);
                    connector.performAdClick(activity);
                }
            }
        });
    }

    @ReactMethod
    public void destroyLoader(final String spotId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                clientCache.remove(spotId);
            }
        });
    }

    @ReactMethod
    public void destroyAd(final int refId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                nativeAdCache.remove(refId);
            }
        });
    }

    private WritableMap convertMap(NendAdNative nativeAd, int refId, AdvertisingExplicitly adExplicitly) {
        WritableMap map = Arguments.createMap();
        map.putInt("referenceId", refId);
        map.putString("adImageUrl", nativeAd.getAdImageUrl());
        map.putString("logoImageUrl", nativeAd.getLogoImageUrl() != null ? nativeAd.getLogoImageUrl() : "");
        map.putString("title", nativeAd.getTitleText());
        map.putString("content", nativeAd.getContentText());
        map.putString("promotionName", nativeAd.getPromotionName());
        map.putString("promotionUrl", nativeAd.getPromotionUrl());
        map.putString("callToAction", nativeAd.getActionText());
        map.putString("adExplicitly", adExplicitly.getText());
        return map;
    }

}
