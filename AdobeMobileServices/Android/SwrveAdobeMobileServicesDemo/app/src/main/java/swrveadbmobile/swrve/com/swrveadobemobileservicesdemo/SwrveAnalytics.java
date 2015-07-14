package swrveadbmobile.swrve.com.swrveadobemobileservicesdemo;

import java.util.Map;
import com.adobe.mobile.Analytics;
import com.swrve.sdk.SwrveHelper;
import com.swrve.sdk.SwrveSDK;
import com.swrve.sdk.config.SwrveConfig;

public class SwrveAnalytics {
    
    public static void trackState(final String state, Map<String, Object> contextData) {
        Analytics.trackState(state, contextData);
    }

    public static void trackAction(final String action, Map<String, Object> contextData) {
        Analytics.trackAction(action, contextData);
    }

    public static void createInstance(Application app, int appId, String apiKey, SwrveConfig config) {
        String trackingId = Analytics.getTrackingIdentifier();
        if (config == null) {
            config = new SwrveConfig();
        }
        // Use the ADBMobile trackingId as user if if none was configured
        if (SwrveHelper.isNullOrEmpty(config.getUserId())) {
            config.setUserId(trackingId);
        }
        SwrveSDK.createInstance(app, appId, apiKey, config);
    }
}
