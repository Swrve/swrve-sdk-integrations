package com.phonegap.helloworld;

import com.swrve.sdk.SwrveSDK;
import com.swrve.sdk.config.SwrveConfig;

public class Application extends android.app.Application {

    @Override
    public void onCreate() {
        // Initialise the Swrve SDK with your configuration
        // SwrveSDK.createInstance(this, 1, "your_api_key");

        // Initialise the Swrve SDK with your configuration
        // Optional: Google GCM configuration
        SwrveConfig config = new SwrveConfig();
        config.setSenderId("334691050849");
        SwrveSDK.createInstance(this, 1330, "OFLRPjJWrrQ6yTr2HNpv", config);
    }
}