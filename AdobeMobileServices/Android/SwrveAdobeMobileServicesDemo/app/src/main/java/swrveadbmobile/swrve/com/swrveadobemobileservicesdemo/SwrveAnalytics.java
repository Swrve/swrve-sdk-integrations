package swrveadbmobile.swrve.com.swrveadobemobileservicesdemo;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import com.adobe.mobile.Analytics;
import com.swrve.sdk.SwrveHelper;
import com.swrve.sdk.SwrveSDK;
import com.swrve.sdk.config.SwrveConfig;

public class SwrveAnalytics {

    public static void trackState(final String state, Map<String, Object> contextData) {
        // By default we only use the contextData
        SwrveSDK.userUpdate(convertToSwrveCompatibleMap(contextData));
        Analytics.trackState(state, contextData);
    }

    public static void trackAction(final String action, Map<String, Object> contextData) {
        // By default the event name and context data will be kept the same
        SwrveSDK.event(action, convertToSwrveCompatibleMap(contextData));
        Analytics.trackAction(action, contextData);
    }

    private static Map<String, String> convertToSwrveCompatibleMap(Map<String, Object> contextData) {
        Map<String, String> result = new HashMap<String, String>();
        Iterator<String> keysIt = contextData.keySet().iterator();
        while(keysIt.hasNext()) {
            String key = keysIt.next();
            String value = contextData.get(key).toString();
            result.put(key, value);
        }

        return result;
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
