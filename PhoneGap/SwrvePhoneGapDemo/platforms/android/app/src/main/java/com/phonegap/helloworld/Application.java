package com.phonegap.helloworld;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

import com.swrve.SwrvePlugin;
import com.swrve.sdk.config.SwrveConfig;

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
            // Default channel notification configuration
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                NotificationChannel channel = new NotificationChannel("default", "Default", NotificationManager.IMPORTANCE_DEFAULT);
                config.setDefaultNotificationChannel(channel);
            }
            // Initialise the Swrve SDK with your configuration
            SwrvePlugin.createInstance(this, 1, "api_key", config);
        }
    }

    private boolean isRunningTests() {
        try {
            Class.forName("com.phonegap.helloworld.SwrvePluginTests");
            return true;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }
}
