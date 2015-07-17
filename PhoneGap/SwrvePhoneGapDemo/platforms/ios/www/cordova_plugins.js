cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/nl.x-services.plugins.toast/www/Toast.js",
        "id": "nl.x-services.plugins.toast.Toast",
        "clobbers": [
            "window.plugins.toast"
        ]
    },
    {
        "file": "plugins/nl.x-services.plugins.toast/test/tests.js",
        "id": "nl.x-services.plugins.toast.tests"
    },
    {
        "file": "plugins/com.swrve.SwrvePlugin/js/swrve-ios.js",
        "id": "com.swrve.SwrvePlugin.SwrvePlugin",
        "clobbers": [
            "SwrvePlugin"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "cordova-plugin-whitelist": "1.0.0",
    "nl.x-services.plugins.toast": "2.0.4",
    "com.swrve.SwrvePlugin": "0.0.1"
}
// BOTTOM OF METADATA
});