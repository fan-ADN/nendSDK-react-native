package com.awesomeproject;

import android.content.Context;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.PixelUtil;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.facebook.react.views.view.ReactViewGroup;

import net.nend.android.NendAdInformationListener;
import net.nend.android.NendAdView;

import java.util.Map;

import javax.annotation.Nullable;

public class NendAdViewManager extends ViewGroupManager<NendAdViewManager.ReactNendAdView> {

    private static final String REACT_CLASS = "RCTNendAdView";

    private static final String EVENT_AD_LOADED = "onAdLoaded";
    private static final String EVENT_AD_FAILED_TO_LOAD = "onAdFailedToLoad";
    private static final String EVENT_AD_CLICKED = "onAdClicked";
    private static final String EVENT_INFORMATION_CLICKED = "onInformationClicked";

    private static final int COMMAND_LOAD = 1;
    private static final int COMMAND_RESUME = 2;
    private static final int COMMAND_PAUSE = 3;

    private static final String PROP_SPOT_ID = "spotId";
    private static final String PROP_API_KEY = "apiKey";
    private static final String PROP_ADJUST_SIZE = "adjustSize";

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected ReactNendAdView createViewInstance(ThemedReactContext reactContext) {
        return new ReactNendAdView(reactContext);
    }

    @Nullable
    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>of(
                EVENT_AD_LOADED, MapBuilder.of("registrationName", EVENT_AD_LOADED),
                EVENT_AD_FAILED_TO_LOAD, MapBuilder.of("registrationName", EVENT_AD_FAILED_TO_LOAD),
                EVENT_AD_CLICKED, MapBuilder.of("registrationName", EVENT_AD_CLICKED),
                EVENT_INFORMATION_CLICKED, MapBuilder.of("registrationName", EVENT_INFORMATION_CLICKED));
    }

    @Nullable
    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of(
                "loadAd", COMMAND_LOAD,
                "resume", COMMAND_RESUME,
                "pause", COMMAND_PAUSE);
    }

    @ReactProp(name = PROP_SPOT_ID)
    public void setSpotId(ReactNendAdView view, String spotId) {
        view.setSpotId(spotId);
    }

    @ReactProp(name = PROP_API_KEY)
    public void setApiKey(ReactNendAdView view, String apiKey) {
        view.setApiKey(apiKey);
    }

    @ReactProp(name = PROP_ADJUST_SIZE)
    public void setAdjustSize(ReactNendAdView view, boolean adjustSize) {
        view.setAdjustSize(adjustSize);
    }

    @Override
    public void receiveCommand(ReactNendAdView root, int commandId, @Nullable ReadableArray args) {
        switch (commandId) {
            case COMMAND_LOAD:
                root.getAdView().loadAd();
                break;
            case COMMAND_RESUME:
                root.getAdView().resume();
                break;
            case COMMAND_PAUSE:
                root.getAdView().pause();
                break;
        }
    }

    public static class ReactNendAdView extends ReactViewGroup implements NendAdInformationListener {

        private NendAdView adView;
        private String spotId;
        private String apiKey;
        private boolean isAdjustSize;

        public ReactNendAdView(Context context) {
            super(context);
        }

        public NendAdView getAdView() {
            if (adView == null) {
                adView = new NendAdView(getContext(), Integer.valueOf(spotId), apiKey, isAdjustSize);
                addView(adView, 0, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
                adView.setListener(this);
            }
            return adView;
        }

        public void setSpotId(String spotId) {
            this.spotId = spotId;
        }

        public void setApiKey(String apiKey) {
            this.apiKey = apiKey;
        }

        public void setAdjustSize(boolean adjustSize) {
            isAdjustSize = adjustSize;
        }

        private void sendEvent(Context reactContext,
                               String eventName,
                               @Nullable WritableMap params) {
            ((ReactContext) reactContext)
                    .getJSModule(RCTEventEmitter.class)
                    .receiveEvent(getId(), eventName, params);
        }

        @Override
        public void onReceiveAd(NendAdView nendAdView) {
            final LayoutParams lp = adView.getLayoutParams();
            int width = lp.width;
            int height = lp.height;
            int left = adView.getLeft();
            int top = adView.getTop();

            adView.measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY));
            adView.layout(left, top, left + width, top + height);

            final WritableMap event = Arguments.createMap();
            event.putDouble("width", PixelUtil.toDIPFromPixel((float) width));
            event.putDouble("height", PixelUtil.toDIPFromPixel((float) height));
            sendEvent(getContext(), EVENT_AD_LOADED, event);
        }

        @Override
        public void onFailedToReceiveAd(NendAdView nendAdView) {
            final NendAdView.NendError error = nendAdView.getNendError();
            final WritableMap event = Arguments.createMap();
            event.putInt("code", error.getCode());
            event.putString("message", error.getMessage());
            sendEvent(getContext(), EVENT_AD_FAILED_TO_LOAD, event);
        }

        @Override
        public void onClick(NendAdView nendAdView) {
            sendEvent(getContext(), EVENT_AD_CLICKED, null);
        }

        @Override
        public void onInformationButtonClick(NendAdView nendAdView) {
            sendEvent(getContext(), EVENT_INFORMATION_CLICKED, null);
        }

        @Override
        public void onDismissScreen(NendAdView nendAdView) {
            // nop
        }
    }

}
