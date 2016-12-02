cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/cordova-plugin-console/www/console-via-logger.js",
        "id": "cordova-plugin-console.console",
        "pluginId": "cordova-plugin-console",
        "clobbers": [
            "console"
        ]
    },
    {
        "file": "plugins/cordova-plugin-console/www/logger.js",
        "id": "cordova-plugin-console.logger",
        "pluginId": "cordova-plugin-console",
        "clobbers": [
            "cordova.logger"
        ]
    },
    {
        "file": "plugins/cordova-plugin-x-toast/www/Toast.js",
        "id": "cordova-plugin-x-toast.Toast",
        "pluginId": "cordova-plugin-x-toast",
        "clobbers": [
            "window.plugins.toast"
        ]
    },
    {
        "file": "plugins/cordova-plugin-x-toast/test/tests.js",
        "id": "cordova-plugin-x-toast.tests",
        "pluginId": "cordova-plugin-x-toast"
    },
    {
        "file": "plugins/com.swrve.SwrvePlugin/js/swrve-ios.js",
        "id": "com.swrve.SwrvePlugin.SwrvePlugin",
        "pluginId": "com.swrve.SwrvePlugin",
        "clobbers": [
            "SwrvePlugin"
        ]
    }
];
module.exports.metadata =
// TOP OF METADATA
{
    "cordova-plugin-console": "1.0.3",
    "cordova-plugin-whitelist": "1.2.2",
    "cordova-plugin-x-toast": "2.5.2",
    "com.swrve.SwrvePlugin": "1.0.4"
}
// BOTTOM OF METADATA
});
