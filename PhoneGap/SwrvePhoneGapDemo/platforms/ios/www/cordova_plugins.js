cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
  {
    "id": "com.swrve.SwrvePlugin.SwrvePlugin",
    "file": "plugins/com.swrve.SwrvePlugin/js/swrve-ios.js",
    "pluginId": "com.swrve.SwrvePlugin",
    "clobbers": [
      "SwrvePlugin"
    ]
  },
  {
    "id": "cordova-plugin-x-toast.Toast",
    "file": "plugins/cordova-plugin-x-toast/www/Toast.js",
    "pluginId": "cordova-plugin-x-toast",
    "clobbers": [
      "window.plugins.toast"
    ]
  },
  {
    "id": "cordova-plugin-x-toast.tests",
    "file": "plugins/cordova-plugin-x-toast/test/tests.js",
    "pluginId": "cordova-plugin-x-toast"
  }
];
module.exports.metadata = 
// TOP OF METADATA
{
  "com.swrve.SwrvePlugin": "1.2.0",
  "cordova-plugin-whitelist": "1.2.2",
  "cordova-plugin-x-toast": "2.5.2"
};
// BOTTOM OF METADATA
});