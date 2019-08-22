package net.nend.reactmodule;

import android.content.Context;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import net.nend.android.NendAdNativeMediaView;
import net.nend.android.NendAdNativeMediaViewListener;
import net.nend.android.NendAdNativeVideo;

import java.util.Map;

import javax.annotation.Nullable;

public class NendMediaViewManager extends ViewGroupManager<NendMediaViewManager.ReactNendMediaView> {

    private static final String REACT_CLASS = "RCTNendMediaView";

    private static final String EVENT_START_PLAY = "onPlaybackStarted";
    private static final String EVENT_STOP_PLAY = "onPlaybackStopped";
    private static final String EVENT_COMPLETED_PLAY = "onPlaybackCompleted";
    private static final String EVENT_OPEN_FULL_SCREEN = "onFullScreenOpened";
    private static final String EVENT_CLOSE_FULL_SCREEN = "onFullScreenClosed";
    private static final String EVENT_ERROR = "onPlaybackError";

    private static final int COMMAND_SET_MEDIA = 1;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected ReactNendMediaView createViewInstance(ThemedReactContext reactContext) {
        return new ReactNendMediaView(reactContext);
    }

    @Nullable
    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>of(
                EVENT_START_PLAY, MapBuilder.of("registrationName", EVENT_START_PLAY),
                EVENT_STOP_PLAY, MapBuilder.of("registrationName", EVENT_STOP_PLAY),
                EVENT_COMPLETED_PLAY, MapBuilder.of("registrationName", EVENT_COMPLETED_PLAY),
                EVENT_OPEN_FULL_SCREEN, MapBuilder.of("registrationName", EVENT_OPEN_FULL_SCREEN),
                EVENT_CLOSE_FULL_SCREEN, MapBuilder.of("registrationName", EVENT_CLOSE_FULL_SCREEN),
                EVENT_ERROR, MapBuilder.of("registrationName", EVENT_ERROR));
    }

    @Nullable
    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of("setMedia", COMMAND_SET_MEDIA);
    }

    @Override
    public void receiveCommand(ReactNendMediaView root, int commandId, @Nullable ReadableArray args) {
        if (commandId == COMMAND_SET_MEDIA) {
            final ReactContext context = (ReactContext) root.getContext();
            final NendVideoNativeAdModule module = context.getNativeModule(NendVideoNativeAdModule.class);
            if (module != null && args != null) {
                final int refId = args.getInt(0);
                final NendAdNativeVideo videoAd = module.getVideoNativeAdCache(refId);
                if (videoAd != null && videoAd.hasVideo()) {
                    root.setMedia(videoAd);
                }
            }
        }
    }

    public static class ReactNendMediaView extends FrameLayout implements NendAdNativeMediaViewListener {

        private final NendAdNativeMediaView mediaView;

        public ReactNendMediaView(Context context) {
            super(context);
            mediaView = new NendAdNativeMediaView(context);
            mediaView.setMediaViewListener(this);
            addView(mediaView, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }

        @Override
        public void requestLayout() {
            Log.d("ReactNativeJS", "requestLayout");
            super.requestLayout();
        }

        private void setMedia(NendAdNativeVideo videoAd) {
            mediaView.setMedia(videoAd);
            //updatedMeasureSizes((ViewGroup) mediaView.getChildAt(0));
        }

        //Note : このメソッドは本来SDK処理内にてConstraintLayoutで指定しているレイアウトが
        //       ReactNative上で動作しない問題を回避するために強引にレイアウト補正する処理です...
        private void updatedMeasureSizes(ViewGroup root) {
            ViewGroup layout = (ViewGroup) root.getChildAt(1);
            if (layout == null) {
                layout = (ViewGroup) root.getChildAt(0);
                if (layout == null) {
                    layout = root;
                }
            }
            System.out.println("height: "+ layout.getHeight());
            System.out.println("width: "+ layout.getWidth());
            System.out.println("mediaView height: "+ mediaView.getHeight());
            System.out.println("mediaView width: "+ mediaView.getWidth());

            layout.measure(MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
            //layout.layout(0, 0, layout.getMeasuredWidth(), layout.getMeasuredHeight());

            root.layout(0, 0, mediaView.getWidth(), mediaView.getHeight());
            layout.layout(0, 0, mediaView.getWidth(), mediaView.getHeight());
            layout.invalidate();
            root.invalidate();
            mediaView.invalidate();
        }

        private void sendEvent(String eventName, @Nullable WritableMap params) {
            ((ReactContext) getContext()).getJSModule(RCTEventEmitter.class).receiveEvent(getId(), eventName, params);
        }

        @Override
        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec);

            final int width = getMeasuredWidth();
            final int height = getMeasuredHeight();

            Log.d("ReactNativeJS", "ReactNendMediaView#onMeasure: "
                    + MeasureSpec.toString(widthMeasureSpec) + ", " + MeasureSpec.toString(heightMeasureSpec));

            mediaView.measure(
                    MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY));
        }

        @Override
        protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
            mediaView.layout(0, 0, right - left, bottom - top);
        }

        @Override
        public void onStartPlay(NendAdNativeMediaView nendAdNativeMediaView) {
            sendEvent(EVENT_START_PLAY, null);
        }

        @Override
        public void onStopPlay(NendAdNativeMediaView nendAdNativeMediaView) {
            sendEvent(EVENT_STOP_PLAY, null);
        }

        @Override
        public void onCompletePlay(NendAdNativeMediaView nendAdNativeMediaView) {
            updatedMeasureSizes((ViewGroup) mediaView.getChildAt(1));
            sendEvent(EVENT_COMPLETED_PLAY, null);
        }

        @Override
        public void onOpenFullScreen(NendAdNativeMediaView nendAdNativeMediaView) {
            sendEvent(EVENT_OPEN_FULL_SCREEN, null);
        }

        @Override
        public void onCloseFullScreen(NendAdNativeMediaView nendAdNativeMediaView) {
            sendEvent(EVENT_CLOSE_FULL_SCREEN, null);
        }

        @Override
        public void onError(int i, String s) {
            WritableMap params = Arguments.createMap();
            params.putInt("code", i);
            params.putString("message", s);
            sendEvent(EVENT_ERROR, params);
        }

    }

}