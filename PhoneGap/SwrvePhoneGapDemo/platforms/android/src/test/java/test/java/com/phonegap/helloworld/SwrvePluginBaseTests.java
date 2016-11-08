package test.java.com.phonegap.helloworld;

import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Bundle;;
import android.test.ActivityInstrumentationTestCase2;
import com.swrve.SwrvePlugin;
import com.swrve.sdk.SwrveSDKBase;
import com.swrve.sdk.config.SwrveConfig;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Properties;
import java.util.concurrent.Semaphore;

public abstract class SwrvePluginBaseTests extends ActivityInstrumentationTestCase2<MainTestActivity> {

    protected MainTestActivity mActivity;
    protected int returnCode;

    protected MockHttpServer httpEventServer;
    protected MockHttpServer httpContentServer;

    protected ArrayList<String> lastEventBatches;

    public SwrvePluginBaseTests() {
        super(MainTestActivity.class);
    }

    public void setUp() throws Exception {
        super.setUp();

        returnCode = 0;
        lastEventBatches = new ArrayList<String>();

        final Context context = getInstrumentation().getTargetContext().getApplicationContext();
        applicationOnCreate(context);

        // Setup mock servers
        httpEventServer = new MockHttpServer();
        httpEventServer.start(8085, new File("."));

        httpContentServer = new MockHttpServer();
        httpContentServer.start(8083, new File("."));
        // Mock image response
        httpContentServer.setHandler("/cdn/", new MockHttpServer.IMockHttpServerHandler() {
            @Override
            public NanoHTTPD.Response serve(String uri, String method, Properties header, Properties params) {
                try {
                    AssetManager assetManager = context.getAssets();
                    InputStream in = assetManager.open(uri.replace("/cdn/", ""));
                    return new NanoHTTPD.Response(NanoHTTPD.HTTP_OK, "image/png", in);
                } catch (IOException e) {
                    e.printStackTrace();
                }
                return null;
            }
        });

        // Mock user resources and user resources diff
        final String campaignsAndResourcesJSON = getResourceAsText(context, "test_campaigns_and_resources.json");
        httpContentServer.setResponseHandler("/api/1/user_resources_and_campaigns", "application/json", campaignsAndResourcesJSON);
        final String resourcesDiffJSON = "[{ \"uid\": \"house\", \"diff\": { \"cost\": { \"old\": \"550\", \"new\": \"666\" }}}]";
        httpContentServer.setResponseHandler("/api/1/user_resources_diff", "application/json", resourcesDiffJSON);

        // Mock events api
        httpEventServer.setHandler("1/batch", new MockHttpServer.IMockHttpServerHandler() {
            @Override
            public NanoHTTPD.Response serve(String uri, String method, Properties header, Properties params) {
                String body = (String)params.get("jsonData");
                synchronized (lastEventBatches) {
                    lastEventBatches.add(body);
                }
                return new NanoHTTPD.Response(NanoHTTPD.HTTP_OK, "application/json", "");
            }
        });

        // Start activity and SDK
        mActivity = getActivity();
        assertNotNull(mActivity);

        // Wait for page to load...
        for (int i = 0; i < 60 && !mActivity.isPageFinishedLoading(); i++) {
            Thread.sleep(1000);
        }
        assertTrue(mActivity.isPageFinishedLoading());

        // Wait for plugin to be loaded
        String pluginLoaded = null;
        for (int i = 0; i < 10 && pluginLoaded == null; i++) {
            runJS("if (window !== undefined && 'plugins' in window && 'swrve' in window.plugins) { alert('swrve:99:yes'); }");
            pluginLoaded = mActivity.getJSReturnValue(99);
            if (pluginLoaded == null) {
                Thread.sleep(1000);
            }
        }
        mActivity.clearJSReturnValues();
        assertNotNull(pluginLoaded);
    }

    public void tearDown() throws Exception {
        super.tearDown();
        mActivity.finish();
        mActivity = null;
        if (httpEventServer != null) {
            httpEventServer.stop();
            httpEventServer = null;
        }
        if (httpContentServer != null) {
            httpContentServer.stop();
            httpContentServer = null;
        }
    }

    private String getResourceAsText(Context context, String filename) {
        String result = null;
        try {
            InputStream in = context.getAssets().open(filename);
            assertNotNull(in);
            java.util.Scanner s = new java.util.Scanner(in).useDelimiter("\\A");
            result = s.hasNext() ? s.next() : "";
            assertFalse(result.length() == 0);
        } catch (IOException e) {
            e.printStackTrace();
            fail("Error reading asset file " + filename);
        }
        return result;
    }

    private void applicationOnCreate(final Context context) throws Exception {
        // Clean any previous instance of the SDK
        Field instanceField = SwrveSDKBase.class.getDeclaredField("instance");
        instanceField.setAccessible(true);
        instanceField.set(null, null);

        // Init SDK
        SwrveConfig config = new SwrveConfig();
        try {
            config.setContentUrl(new URL("http://localhost:8083"));
            config.setEventsUrl(new URL("http://localhost:8085"));
            config.setSenderId("fake_sender_id");
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        SwrvePlugin.createInstance(context, 1, "your_api_key", config);
    }

    protected void runJS(final String js) {
        final Semaphore mutex = new Semaphore(0);
        mActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mActivity.runJS(js);
                mutex.release();
            }
        });
        try {
            mutex.acquire();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    protected EventChecker returnFailedChecker(ArrayList<EventChecker> eventChecks) throws JSONException {
        ArrayList<JSONObject> events = new ArrayList<JSONObject>();
        synchronized (lastEventBatches) {
            for (String batchJSON : lastEventBatches) {
                JSONObject batch = new JSONObject(batchJSON);
                JSONArray data = batch.getJSONArray("data");
                for (int i = 0; i < data.length(); i++) {
                    events.add(data.getJSONObject(i));
                }
            }
        }

        for(EventChecker eventChecker : eventChecks) {
            boolean checkPasses = false;
            for (JSONObject event : events) {
                if (eventChecker.check(event)) {
                    checkPasses = true;
                    break;
                }
            }
            if (!checkPasses) {
                return eventChecker;
            }
        }
        return null;
    }

    protected Intent getGcmIntent(int id, String extraName, String extraValue) {
        Intent gcmIntent = new Intent();
        Bundle bundle = new Bundle();
        Bundle notificationBundle = new Bundle();
        notificationBundle.putString("_p", "" + id);
        notificationBundle.putString(extraName, extraValue);
        bundle.putBundle("notification", notificationBundle);
        gcmIntent.putExtras(bundle);
        return gcmIntent;
    }

    protected abstract class EventChecker {
        private String name;

        public EventChecker(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }

        public abstract boolean check(JSONObject event);
    }
}
