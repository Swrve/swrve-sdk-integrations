package com.swrve;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Base64;

import org.apache.cordova.Whitelist;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.Set;

import com.swrve.sdk.SwrveSDK;
import com.swrve.sdk.gcm.ISwrvePushNotificationListener;
import com.swrve.sdk.messaging.ISwrveCustomButtonListener;
import com.swrve.sdk.runnable.UIThreadSwrveResourcesRunnable;
import com.swrve.sdk.UIThreadSwrveUserResourcesListener;
import com.swrve.sdk.runnable.UIThreadSwrveResourcesDiffRunnable;
import com.swrve.sdk.UIThreadSwrveUserResourcesDiffListener;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.xmlpull.v1.XmlPullParser;

public class SwrvePlugin extends CordovaPlugin {

    private static SwrvePlugin instance;

    // Used when instantiated via reflection by PluginManager
    public SwrvePlugin() {
        super();
        instance = this;
    }

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        // Activity started
        SwrveSDK.onCreate(cordova.getActivity());
    }

    private HashMap<String, String> getMapFromJSON(JSONObject json) throws JSONException {
        HashMap<String, String> map = new HashMap<String, String>();

        for (Iterator<String> iterator = json.keys(); iterator.hasNext(); ) {
            String key = iterator.next();
            String value = json.getString(key);
            map.put(key, value);
        }
        return map;
    }

    private boolean isBadArgument(JSONArray arguments, CallbackContext callbackContext, int requiredSize, String msg) {
        if (arguments.length() < requiredSize) {
            System.err.println(msg);
            callbackContext.error(msg);
            return true;
        }
        return false;
    }

    private void sendEvent(JSONArray arguments, final CallbackContext callbackContext) {
        try {
            final String name = arguments.getString(0);
            // payload is optional
            if (arguments.length() > 1) {
                JSONObject payloads = arguments.getJSONObject(1);
                final HashMap<String, String> map = getMapFromJSON(payloads);
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        SwrveSDK.event(name, map);
                        callbackContext.success();
                    }
                });
            } else {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        SwrveSDK.event(name);
                        callbackContext.success();
                    }
                });
            }
        } catch (JSONException e) {
            callbackContext.error("JSON_EXCEPTION");
            e.printStackTrace();
        }
    }

    private void sendUserUpdate(JSONArray arguments, final CallbackContext callbackContext) {
        try {
            JSONObject updates = arguments.getJSONObject(0);
            final HashMap<String, String> map = getMapFromJSON(updates);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    SwrveSDK.userUpdate(map);
                    callbackContext.success();
                }
            });
        } catch (JSONException e) {
            callbackContext.error("JSON_EXCEPTION");
            e.printStackTrace();
        }
    }

    private void sendCurrencyGiven(JSONArray arguments, final CallbackContext callbackContext) {
        try {
            final String currency = arguments.getString(0);
            final int quantity = arguments.getInt(1);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    SwrveSDK.currencyGiven(currency, quantity);
                    callbackContext.success();
                }
            });
        } catch (JSONException e) {
            callbackContext.error("JSON_EXCEPTION");
            e.printStackTrace();
        }
    }

    private void sendPurchase(JSONArray arguments, final CallbackContext callbackContext) {
        try {
            final String name = arguments.getString(0);
            final String currency = arguments.getString(1);
            final int quantity = arguments.getInt(2);
            final int cost = arguments.getInt(3);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    SwrveSDK.purchase(name, currency, cost, quantity);
                    callbackContext.success();
                }
            });
        } catch (JSONException e) {
            callbackContext.error("JSON_EXCEPTION");
            e.printStackTrace();
        }
    }

    private void sendIap(JSONArray arguments, final CallbackContext callbackContext) {
        try {
            final int quantity = arguments.getInt(0);
            final String productId = arguments.getString(1);
            final double price = arguments.getDouble(2);
            final String currency = arguments.getString(3);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    SwrveSDK.iap(quantity, productId, price, currency);
                    callbackContext.success();
                }
            });
        } catch (JSONException e) {
            callbackContext.error("JSON_EXCEPTION");
            e.printStackTrace();
        }
    }

    @Override
    public boolean execute(final String action, final JSONArray arguments, final CallbackContext callbackContext) {
        if ("event".equals(action)) {
            if (!isBadArgument(arguments, callbackContext, 1, "event arguments need to be supplied.")) {
                sendEvent(arguments, callbackContext);
            }
            return true;

        } else if ("userUpdate".equals(action)) {
            if (!isBadArgument(arguments, callbackContext, 1, "user update arguments need to be supplied.")) {
                sendUserUpdate(arguments, callbackContext);
            }
            return true;

        } else if ("currencyGiven".equals(action)) {
            if (!isBadArgument(arguments, callbackContext, 2, "currency given arguments need to be supplied.")) {
                sendCurrencyGiven(arguments, callbackContext);
            }
            return true;

        } else if ("purchase".equals(action)) {
            if (!isBadArgument(arguments, callbackContext, 4, "purchase arguments need to be supplied.")) {
                sendPurchase(arguments, callbackContext);
            }
            return true;

        } else if ("iap".equals(action)) {
            if (!isBadArgument(arguments, callbackContext, 4, "iap arguments need to be supplied.")) {
                sendIap(arguments, callbackContext);
            }
            return true;

        } else if ("sendEvents".equals(action)) {
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    SwrveSDK.sendQueuedEvents();
                    callbackContext.success();
                }
            });
            return true;

        } else if ("getUserResources".equals(action)) {
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    SwrveSDK.getUserResources(new UIThreadSwrveUserResourcesListener(cordova.getActivity(),
                            new UIThreadSwrveResourcesRunnable() {
                                @Override
                                public void onUserResourcesSuccess(Map<String, Map<String, String>> resources, String resourcesAsJSON) {
                                    callbackContext.success(new JSONObject(resources));
                                }

                                @Override
                                public void onUserResourcesError(Exception exception) {
                                    exception.printStackTrace();
                                    callbackContext.error(exception.getMessage());
                                }
                            }));
                }
            });
            return true;

        } else if ("getUserResourcesDiff".equals(action)) {
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    SwrveSDK.getUserResourcesDiff(new UIThreadSwrveUserResourcesDiffListener(cordova.getActivity(),
                            new UIThreadSwrveResourcesDiffRunnable() {
                                @Override
                                public void onUserResourcesDiffSuccess(Map<String, Map<String, String>> oldResources, Map<String, Map<String, String>> newResources, String resourcesAsJSON) {
                                    try {
                                        callbackContext.success(new JSONObject(resourcesAsJSON));
                                    } catch (JSONException e) {
                                        e.printStackTrace();
                                    }
                                }

                                @Override
                                public void onUserResourcesDiffError(Exception exception) {
                                    exception.printStackTrace();
                                    callbackContext.error(exception.getMessage());
                                }

                            }));
                }
            });
            return true;
        }

        return false;
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        SwrveSDK.onResume(cordova.getActivity());
    }

    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);
        SwrveSDK.onPause();
    }

    @Override
    public void onDestroy() {
        SwrveSDK.onDestroy(cordova.getActivity());
        super.onDestroy();
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        SwrveSDK.processIntent(intent);
    }

    public static ISwrveCustomButtonListener customButtonListener = new ISwrveCustomButtonListener() {
        @Override
        public void onAction(String action) {
            instance.webView.loadUrl("javascript:window.swrveCustomButtonListener('"+ action +"')");
        }
    };

    public static ISwrvePushNotificationListener pushNotificationListener = new ISwrvePushNotificationListener() {

        @Override
        public void onPushNotification(Bundle bundle) {
            JSONObject json = new JSONObject();
            Set<String> keys = bundle.keySet();
            for (String key : keys) {
                try {
                    json.put(key, bundle.get(key));
                } catch(JSONException e) {
                    e.printStackTrace();
                }
            }
            String jsonString = json.toString();
            byte[] jsonBytes = jsonString.getBytes();
            instance.webView.loadUrl("javascript:window.swrvePushNotificationListener('"+ Base64.encodeToString(jsonBytes, Base64.DEFAULT) +"')");
        }
    };
}
