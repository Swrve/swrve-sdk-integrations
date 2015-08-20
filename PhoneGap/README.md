Swrve SDK Cordova Plugin
========================

How to integrate with Android
-----------------------------
1. Install this plugin into your project.
2. Add a custom Application class to platforms/android/your.package.name
3. Initialise the Swrve SDK as follows on onCreate:
  * 
```Java
import com.swrve.SwrvePlugin;
import com.swrve.sdk.SwrveSDK;
import com.swrve.sdk.config.SwrveConfig;
public class Application extends android.app.Application {
    @Override
    public void onCreate() {
        super.onCreate();
        // Optional: Google GCM configuration
        SwrveConfig config = new SwrveConfig();
        config.setSenderId("334691050849");
        // Initialise the Swrve SDK with your configuration
        SwrveSDK.createInstance(this, 1, "your_api_key");
        SwrveSDK.setCustomButtonListener(SwrvePlugin.customButtonListener);
        // Optional: Set a push notification listener
        SwrveSDK.setPushNotificationListener(SwrvePlugin.pushNotificationListener);
    }
}
```

4. Modify the AndroidManifest.xml file to use the new custom Application class
android:name=".Application"
5. (Optional for GCM push) Make the same AndroidManifest.xml modifications as the native SDK in the following doc to your PhoneGap app: http://docs.swrve.com/developer-documentation/advanced-integration/39456203/. If you don't want to use Google GCM pushes you can compile against our standard SDK by changing the plugin's dependency to compile 'com.swrve.sdk.android:swrve:X.X.X'
6. Use window.plugins.swrve and enjoy!

If you have any issues we recommend debugging with [Chrome's Remote Debugging](https://developer.chrome.com/devtools/docs/remote-debugging).

How to integrate with iOS
-----------------------------
1. Install this plugin into your project.
2. Drag the SwrveSDK.framework into General - Embedded Binaries
3. Initialise the Swrve SDK in your AppDelegate.m:
  *
```Objective-C
#import <SwrveSDK/Swrve.h>
    - (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
        [Swrve sharedInstanceWithAppID:1 apiKey:@"your_api_key"];
        // The existing code
    }
```
4. Use window.plugins.swrve and enjoy!

Contributing
------------
We would love to see your contributions! Follow these steps:

1. Fork this repository.
2. Create a branch (`git checkout -b my_awesome_integration`)
3. Commit your changes (`git commit -m "Awesome integration"`)
4. Push to the branch (`git push origin my_awesome_integration`)
5. Open a Pull Request.

License
-------
© Copyright Swrve Mobile Inc or its licensors. Distributed under the [Apache 2.0 License](LICENSE).