package swrveadbmobile.swrve.com.swrveadobemobileservicesdemo;

import com.adobe.mobile.Config;

public class Application extends android.app.Application {

    @Override
    public void onCreate() {
        super.onCreate();
        // We need to call this early on to get access to the trackingId
        Config.setContext(this);

        // Create the shared instance on your application onCreate method
        // Use the SwrveAnalytics method to use the trackingId as userId
        SwrveAnalytics.createInstance(this, 1, "your_api_key", null);
    }
}
