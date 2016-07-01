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
        SwrveConfig config = new SwrveConfig();
        // Optional: Google GCM configuration
        config.setSenderId("your_id");
        // Initialise the Swrve SDK with your configuration
        SwrvePlugin.createInstance(this, 1, "api_key", config);
    }
}