package com.phonegap.helloworld;

import com.swrve.SwrvePlugin;
import com.swrve.sdk.SwrveSDK;
import com.swrve.sdk.config.SwrveConfig;

import java.net.MalformedURLException;
import java.net.URL;

public class Application extends android.app.Application {

    @Override
    public void onCreate() {
        super.onCreate();
        // Optional: Google GCM configuration
        SwrveConfig config = new SwrveConfig();
        //config.setSenderId("your_id");
        // Initialise the Swrve SDK with your configuration
        SwrveSDK.createInstance(this, 1, "your_api_key", config);
        SwrveSDK.setCustomButtonListener(SwrvePlugin.customButtonListener);
        // Optional: Set a push notification listener
        SwrveSDK.setPushNotificationListener(SwrvePlugin.pushNotificationListener);
    }
}