package test.java.com.phonegap.helloworld;

import android.content.Intent;
import android.view.View;
import android.widget.RelativeLayout;

import com.swrve.sdk.ISwrveBase;
import com.swrve.sdk.SwrveBase;
import com.swrve.sdk.SwrveSDK;
import com.swrve.sdk.messaging.view.SwrveButtonView;
import com.swrve.sdk.messaging.view.SwrveDialog;

import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.util.ArrayList;

public class SwrvePluginTests extends SwrvePluginBaseTests {

    // NOTE: Any JS failure might affect the next run. If the UI does not appear
    // in the test run it is a sign that there was an error.

    public void testEvents() throws Exception {
        // Send all instrumented events
        runJS("window.plugins.swrve.event(\"levelup\", undefined, undefined);");
        runJS("window.plugins.swrve.event(\"leveldown\", {\"armor\":\"disabled\"}, undefined, undefined);");
        runJS("window.plugins.swrve.userUpdate({\"phonegap\":\"TRUE\"}, undefined, undefined);");
        runJS("window.plugins.swrve.currencyGiven(\"Gold\", 20, undefined, undefined);");
        runJS("window.plugins.swrve.purchase(\"sword\", \"Gold\", 2, 15, undefined, undefined);");
        runJS("window.plugins.swrve.iap(2, \"sword\", 99.5, \"USD\", undefined, undefined);");
        runJS("window.plugins.swrve.iapPlay(\"iap_item\", 98.5, \"USD\", \"fake_purchase_data\", \"fake_purchase_signature\", undefined, undefined);");
        runJS("window.plugins.swrve.sendEvents(undefined, undefined);");

        // Define events that we should find
        ArrayList<EventChecker> eventChecks = new ArrayList<EventChecker>();
        eventChecks.add(new EventChecker("event") {
            @Override
            public boolean check(JSONObject event) {
                JSONObject payload = event.optJSONObject("payload");
                return event.optString("name", "").equals("levelup") && (payload == null || payload.length() == 0);
            }
        });
        eventChecks.add(new EventChecker("event with payload") {
            @Override
            public boolean check(JSONObject event) {
                JSONObject payload = event.optJSONObject("payload");
                return event.optString("name", "").equals("leveldown") && (payload != null && payload.optString("armor", "").equals("disabled"));
            }
        });
        eventChecks.add(new EventChecker("user update") {
            @Override
            public boolean check(JSONObject event) {
                JSONObject attributes = event.optJSONObject("attributes");
                return event.optString("type", "").equals("user") && (attributes != null && attributes.optString("phonegap", "").equals("TRUE"));
            }
        });
        eventChecks.add(new EventChecker("currency given") {
            @Override
            public boolean check(JSONObject event) {
                return event.optString("type", "").equals("currency_given")
                        && event.optString("given_amount", "").equals("20.0")
                        && event.optString("given_currency", "").equals("Gold");
            }
        });
        eventChecks.add(new EventChecker("purchase") {
            @Override
            public boolean check(JSONObject event) {
                return event.optString("type", "").equals("purchase")
                        && event.optString("quantity", "").equals("2")
                        && event.optString("currency", "").equals("Gold")
                        && event.optString("cost", "").equals("15")
                        && event.optString("item", "").equals("sword");
            }
        });
        eventChecks.add(new EventChecker("iap") {
            @Override
            public boolean check(JSONObject event) {
                return event.optString("type", "").equals("iap")
                        && event.optString("quantity", "").equals("2")
                        && event.optString("local_currency", "").equals("USD")
                        && event.optString("cost", "").equals("99.5")
                        && event.optString("product_id", "").equals("sword")
                        && event.optString("rewards", "").equals("{}");
            }
        });
        eventChecks.add(new EventChecker("iapPlay") {
            @Override
            public boolean check(JSONObject event) {
                return event.optString("type", "").equals("iap")
                        && event.optString("quantity", "").equals("1")
                        && event.optString("local_currency", "").equals("USD")
                        && event.optString("cost", "").equals("98.5")
                        && event.optString("product_id", "").equals("iap_item")
                        && event.optString("receipt", "").equals("fake_purchase_data")
                        && event.optString("receipt_signature", "").equals("fake_purchase_signature")
                        && event.optString("rewards", "").equals("{}");
            }
        });
        // Find events in the sent batches
        int retries = 180;
        EventChecker failedChecker;
        do {
            failedChecker = returnFailedChecker(eventChecks);
            if (failedChecker != null) {
                Thread.sleep(1000);
            }
        } while (retries-- > 0 && failedChecker != null);
        if (failedChecker != null) {
            fail("The following event check failed: " + failedChecker.getName());
        }
    }

    public void testUserResources() throws Exception {
        runJS("window.plugins.swrve.getUserResources(function(resources) {alert('swrve:10:' + JSON.stringify(resources));}, function () {});");

        int retries = 60;
        String userResources;
        do {
            userResources = mActivity.getJSReturnValue(10);
            if (userResources == null) {
                Thread.sleep(1000);
            }
        } while(retries-- > 0 && userResources == null);

        assertNotNull(userResources);
        // Check user resources
        JSONObject userResourcesJSON = new JSONObject(userResources);
        assertEquals("999", userResourcesJSON.getJSONObject("house").getString("cost"));
    }

    public void testUserResourcesDiff() throws Exception {
        runJS("window.plugins.swrve.getUserResourcesDiff(function(resourcesDiff) {alert('swrve:20:' + JSON.stringify(resourcesDiff));}, function () {});");

        int retries = 60;
        String userResourcesDiff;
        do {
            userResourcesDiff = mActivity.getJSReturnValue(20);
            if (userResourcesDiff == null) {
                Thread.sleep(1000);
            }
        } while(retries-- > 0 && userResourcesDiff == null);

        assertNotNull(userResourcesDiff);
        // Check user resources diff
        JSONObject userResourcesDiffJSON = new JSONObject(userResourcesDiff);
        assertEquals("666", userResourcesDiffJSON.getJSONObject("new").getJSONObject("house").getString("cost"));
        assertEquals("550", userResourcesDiffJSON.getJSONObject("old").getJSONObject("house").getString("cost"));
    }

    public void testCustomButtonListener() throws Exception {
        runJS("window.swrveCustomButtonListener = function(action) { alert('swrve:30:' + action); };");
        runJS("window.plugins.swrve.event(\"campaign_trigger\", undefined, undefined);");

        ISwrveBase sdk = SwrveSDK.getInstance();
        Field dialogField = SwrveBase.class.getSuperclass().getDeclaredField("currentDialog");
        dialogField.setAccessible(true);

        WeakReference<SwrveDialog> weakDialog;
        SwrveDialog dialog = null;
        int retries = 60;
        do {
            runJS("window.plugins.swrve.event(\"campaign_trigger\", undefined, undefined);");
            weakDialog = (WeakReference<SwrveDialog>) dialogField.get(sdk);
            if (weakDialog == null || weakDialog.get() == null) {
                Thread.sleep(1000);
            } else {
                dialog = weakDialog.get();
            }
        } while(retries-- > 0 && (weakDialog == null || weakDialog.get() == null));
        assertNotNull(dialog);

        boolean clickedButton = false;
        RelativeLayout innerMessage = (RelativeLayout) dialog.getInnerView().getChildAt(0);
        int childrenViewsCount = innerMessage.getChildCount();
        for(int i = 0; i < childrenViewsCount; i++) {
            final View childView = innerMessage.getChildAt(i);
            if (childView instanceof SwrveButtonView) {
                clickedButton = true;
                mActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        childView.performClick();
                    }
                });
            }
        }
        assertTrue(clickedButton);

        // Obtain the action from the button
        retries = 60;
        String customAction;
        do {
            customAction = mActivity.getJSReturnValue(30);
            if (customAction == null) {
                Thread.sleep(1000);
            }
        } while(retries-- > 0 && customAction == null);
        assertEquals("custom_action_from_server", customAction);
    }

    public void testCustomPushPayloadListener() throws Exception {
        runJS("window.swrvePushNotificationListener = function(payload) { alert('swrve:40:' + payload); };");

        int retries = 20;
        String payloadJSON;
        do {
            Intent intent = getGcmIntent(retries, "custom", "custom_payload");
            SwrveSDK.processIntent(intent);
            payloadJSON = mActivity.getJSReturnValue(40);
            if (payloadJSON == null) {
                Thread.sleep(1000);
            }
        } while(retries-- > 0 && payloadJSON == null);
        assertNotNull(payloadJSON);
    }
}
