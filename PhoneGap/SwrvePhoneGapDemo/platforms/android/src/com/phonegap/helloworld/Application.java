package com.phonegap.helloworld;

import com.swrve.sdk.SwrveSDK;

public class Application extends android.app.Application {

    @Override
    public void onCreate() {
        // Initialise the Swrve SDK with your configuration
        SwrveSDK.createInstance(this, 1, "your_api_key");
    }
}