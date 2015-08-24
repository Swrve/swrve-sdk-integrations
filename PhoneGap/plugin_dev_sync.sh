#!/bin/bash
# Expand dev changes to the demo PhoneGap app
set -e

PLUGIN="SwrvePlugin"
DEMO="SwrvePhoneGapDemo"
DEMOIOS="SwrvePhoneGapDemo/platforms/ios"
DEMOANDROID="SwrvePhoneGapDemo/platforms/android"

# Global plugin
cp -R $PLUGIN/ $DEMO/plugins/com.swrve.SwrvePlugin/

# Android platform
cp $PLUGIN/platforms/android/build.gradle $DEMOANDROID/com.swrve.SwrvePlugin/helloworld-build.gradle
cp $PLUGIN/platforms/android/src/com/swrve/SwrvePlugin.java $DEMOANDROID/src/com/swrve/SwrvePlugin.java
cp $PLUGIN/js/swrve-android.js $DEMOANDROID/assets/www/plugins/com.swrve.SwrvePlugin/js/swrve-android.js.original
# Add JS plugin wrappings
sed '1i\
cordova.define("com.swrve.SwrvePlugin.SwrvePlugin", function(require, exports, module) {' $DEMOANDROID/assets/www/plugins/com.swrve.SwrvePlugin/js/swrve-android.js.original > $DEMOANDROID/assets/www/plugins/com.swrve.SwrvePlugin/js/swrve-android.js
echo "});" >> $DEMOANDROID/assets/www/plugins/com.swrve.SwrvePlugin/js/swrve-android.js
rm $DEMOANDROID/assets/www/plugins/com.swrve.SwrvePlugin/js/swrve-android.js.original

# iOS platform
cp -R $PLUGIN/platforms/ios/ $DEMOIOS/Hello\ World/Plugins/com.swrve.SwrvePlugin/
cp $PLUGIN/js/swrve-ios.js $DEMOIOS/www/plugins/com.swrve.SwrvePlugin/js/swrve-ios.js.original
# Add JS plugin wrappings
sed '1i\
cordova.define("com.swrve.SwrvePlugin.SwrvePlugin", function(require, exports, module) {' $DEMOIOS/www/plugins/com.swrve.SwrvePlugin/js/swrve-ios.js.original > $DEMOIOS/www/plugins/com.swrve.SwrvePlugin/js/swrve-ios.js
echo "});" >> $DEMOIOS/www/plugins/com.swrve.SwrvePlugin/js/swrve-ios.js
rm $DEMOIOS/www/plugins/com.swrve.SwrvePlugin/js/swrve-ios.js.original