package swrveadbmobile.swrve.com.swrveadobemobileservicesdemo;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import com.adobe.mobile.*;
import com.swrve.sdk.SwrveSDK;

import java.util.HashMap;

public class MainActivity extends ActionBarActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        // Call the SwrveSDK lifecycle callbacks
        SwrveSDK.onCreate(this);

        // Adobe - track when this state loads
        // Replace your calls to Analytics with SwrveAnalytics
        // Analytics.trackState("State Name", null);
        SwrveAnalytics.trackState("State Name", null);

        // Adobe - track action
        HashMap<String, Object> exampleContextData = new HashMap<String, Object>();
        exampleContextData.put("myapp.social.SocialSource", "Twitter");
        // Replace your calls to Analytics with SwrveAnalytics
        //Analytics.trackAction("myapp.SocialShare", exampleContextData);
        SwrveAnalytics.trackAction("myapp.SocialShare", exampleContextData);
    }

    @Override
    public void onResume() {
        super.onResume();
        // Call the SwrveSDK lifecycle callbacks
        SwrveSDK.onResume(this);
        Config.collectLifecycleData(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        // Call the SwrveSDK lifecycle callbacks
        SwrveSDK.onPause();
        Config.pauseCollectingLifecycleData();
    }

    @Override
    protected void onDestroy() {
        // Call the SwrveSDK lifecycle callbacks
        SwrveSDK.onDestroy(this);
        super.onDestroy();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        // Call the SwrveSDK lifecycle callbacks
        SwrveSDK.onLowMemory();
    }
}
