package com.awesomeproject;

import android.util.SparseArray;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.UiThreadUtil;

import net.nend.android.NendAdUserFeature;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import javax.annotation.Nullable;

@SuppressWarnings("unused")
public class NendUserFeatureModule extends ReactContextBaseJavaModule {

    private static final String REACT_CLASS = "NendUserFeature";
    private static final NendAdUserFeature.Gender[] GENDERS = {NendAdUserFeature.Gender.MALE, NendAdUserFeature.Gender.FEMALE};
    private AtomicInteger referenceId = new AtomicInteger(0);
    private SparseArray<NendAdUserFeature.Builder> builders = new SparseArray<>();

    public NendUserFeatureModule(ReactApplicationContext reactContext) {
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
        map.put("Male", 0);
        map.put("Female", 1);
        return map;
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    public int create() {
        final int refId = referenceId.incrementAndGet();
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                builders.put(refId, new NendAdUserFeature.Builder());
            }
        });
        return refId;
    }

    @ReactMethod
    public void setGender(final int refId, final int gender) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NendAdUserFeature.Builder builder = builders.get(refId);
                if (builder != null) {
                    builder.setGender(GENDERS[gender]);
                }
            }
        });
    }

    @ReactMethod
    public void setAge(final int refId, final int age) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NendAdUserFeature.Builder builder = builders.get(refId);
                if (builder != null) {
                    builder.setAge(age);
                }
            }
        });
    }

    @ReactMethod
    public void setBirthday(final int refId, final int year, final int month, final int day) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NendAdUserFeature.Builder builder = builders.get(refId);
                if (builder != null) {
                    builder.setBirthday(year, month, day);
                }
            }
        });
    }

    @ReactMethod
    public void addCustomStringValue(final int refId, final String key, final String value) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NendAdUserFeature.Builder builder = builders.get(refId);
                if (builder != null) {
                    builder.addCustomFeature(key, value);
                }
            }
        });
    }

    @ReactMethod
    public void addCustomBooleanValue(final int refId, final String key, final boolean value) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NendAdUserFeature.Builder builder = builders.get(refId);
                if (builder != null) {
                    builder.addCustomFeature(key, value);
                }
            }
        });
    }

    @ReactMethod
    public void addCustomIntegerValue(final int refId, final String key, final int value) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NendAdUserFeature.Builder builder = builders.get(refId);
                if (builder != null) {
                    builder.addCustomFeature(key, value);
                }
            }
        });
    }

    @ReactMethod
    public void addCustomDoubleValue(final int refId, final String key, final double value) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                NendAdUserFeature.Builder builder = builders.get(refId);
                if (builder != null) {
                    builder.addCustomFeature(key, value);
                }
            }
        });
    }

    @ReactMethod
    public void destroy(final int refId) {
        UiThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                builders.remove(refId);
            }
        });
    }

    NendAdUserFeature.Builder getBuilder(int refId) {
        return builders.get(refId);
    }

}
