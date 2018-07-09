package com.awesomeproject;

import android.app.Activity;
import android.support.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;

import net.nend.android.NendAdRewardedVideo;

public class NendRewardedVideoAdModule extends NendVideoAdModule<NendAdRewardedVideo> {

    private static final String REACT_CLASS = "NendRewardedVideoAd";

    public NendRewardedVideoAdModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected NendAdRewardedVideo createInstance(Activity activity, int spotId, String apiKey) {
        NendAdRewardedVideo videoAd = new NendAdRewardedVideo(activity, spotId, apiKey);
        videoAd.setAdListener(this);
        return videoAd;
    }

    @NonNull
    @Override
    String getEventName() {
        return "RewardedVideoAdEventListener";
    }

}
