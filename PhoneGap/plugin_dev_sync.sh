#!/bin/bash
# Expand dev changes to the demo PhoneGap app
set -e

PLUGIN="SwrvePlugin"
DEMO="SwrvePhoneGapDemo"
DEMOIOS="SwrvePhoneGapDemo/platforms/ios"
DEMOIANDROID="SwrvePhoneGapDemo/platforms/android"

# Global plugin
cp -R $PLUGIN/ $DEMO/com.swrve.SwrvePlugin/

# Android platform
cp $PLUGIN/platforms/android/build.gradle $DEMOIANDROID/com.swrve.SwrvePlugin/helloworld-build.gradle
cp $PLUGIN/platforms/android/src/com/swrve/SwrvePlugin.java $DEMOIANDROID/src/com/swrve/SwrvePlugin.java
cp -R $PLUGIN/js/swrve-android.js $DEMOIANDROID/assets/www/plugins/com.swrve.SwrvePlugin/js/swrve-android.js

# iOS platform
cp -R $PLUGIN/platforms/ios/ $DEMOIOS/Hello\ World/Plugins/com.swrve.SwrvePlugin/
cp -R $PLUGIN/js/swrve-ios.js $DEMOIOS/www/plugins/com.swrve.SwrvePlugin/js/swrve-ios.js