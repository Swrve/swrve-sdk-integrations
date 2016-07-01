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

        // NOTE: Only needed to check if this project is running tests
        // not necessary in your project
        if (!isRunningTests()) {
            SwrveConfig config = new SwrveConfig();
            // Optional: Google GCM configuration
            config.setSenderId("your_id");
            // Initialise the Swrve SDK with your configuration
            SwrvePlugin.createInstance(this, 1, "api_key", config);
        }
    }

    private boolean isRunningTests() {
        try {
            Class.forName("test.java.com.phonegap.helloworld.SwrvePluginTests");
            return true;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }
}
