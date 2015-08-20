package com.phonegap.helloworld;

import com.swrve.SwrvePlugin;
import com.swrve.sdk.SwrveSDK;
import com.swrve.sdk.config.SwrveConfig;

public class Application extends android.app.Application {

    @Override
    public void onCreate() {
        super.onCreate();
        // Optional: Google GCM configuration
        SwrveConfig config = new SwrveConfig();
        config.setSenderId("334691050849");
        // Initialise the Swrve SDK with your configuration
        SwrveSDK.createInstance(this, 1, "your_api_key");
        SwrveSDK.setCustomButtonListener(SwrvePlugin.customButtonListener);
        // Optional: Set a push notification listener
        SwrveSDK.setPushNotificationListener(SwrvePlugin.pushNotificationListener);
    }
}