cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/cordova-plugin-x-toast/www/Toast.js",
        "id": "cordova-plugin-x-toast.Toast",
        "clobbers": [
            "window.plugins.toast"
        ]
    },
    {
        "file": "plugins/cordova-plugin-x-toast/test/tests.js",
        "id": "cordova-plugin-x-toast.tests"
    },
    {
        "file": "plugins/com.swrve.SwrvePlugin/js/swrve-android.js",
        "id": "com.swrve.SwrvePlugin.SwrvePlugin",
        "clobbers": [
            "SwrvePlugin"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "cordova-plugin-whitelist": "1.2.2",
    "cordova-plugin-x-toast": "2.5.2",
    "cordova-plugin-console": "1.0.3",
    "com.swrve.SwrvePlugin": "1.0.3"
};
// BOTTOM OF METADATA
});