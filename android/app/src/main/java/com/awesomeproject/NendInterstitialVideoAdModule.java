package com.awesomeproject;

import android.app.Activity;
import android.support.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.UiThreadUtil;

import net.nend.android.NendAdInterstitialVideo;

public class NendInterstitialVideoAdModule extends NendVideoAdModule<NendAdInterstitialVideo> {

    private static final String REACT_CLASS = "NendInterstitialVideoAd";

    public NendInterstitialVideoAdModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    NendAdInterstitialVideo createInstance(Activity activity, int spotId, String apiKey) {
        NendAdInterstitialVideo videoAd = new NendAdInterstitialVideo(activity, spotId, apiKey);
        videoAd.setAdListener(this);
        return videoAd;
    }

    @NonNull
    @Override
    String getEventName() {
        return "InterstitialVideoAdEventListener";
    }

    @ReactMethod
    public void addFallbackFullBoard(final String spotId, final String fallbackSpotId, final String fallbackApiKey) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final NendAdInterstitialVideo videoAd = getInstance(spotId);
                if (videoAd != null) {
                    try {
                        videoAd.addFallbackFullboard(Integer.valueOf(fallbackSpotId), fallbackApiKey);
                    } catch (NumberFormatException ignore) {
                    }
                }
            }
        });
    }

}
