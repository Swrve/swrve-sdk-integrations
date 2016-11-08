// Capture Javascript errors
window.onerror = function (errorMsg, url, lineNumber, column, errorObj) {
    window.plugins.toast.showShortTop(errorMsg + lineNumber + errorObj);
}

var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    onDeviceReady: function() {
        var parentElement = document.getElementById('swrve-panel');
        parentElement.setAttribute('style','display:block;');

        // Set new resources listener
        window.plugins.swrve.setResourcesListener(function(resources) {
            window.plugins.toast.showShortTop("Resources updated: " + JSON.stringify(resources));
        });
        // Set IAM custom button listener
        window.plugins.swrve.setCustomButtonListener(function(action) {
            window.plugins.toast.showShortTop("IAM custom button clicked: " + action);
        });
        // Set push payload listener
        window.plugins.swrve.setPushNotificationListener(function(payload) {
            window.plugins.toast.showShortTop("Push payload: " + payload);
        });

        parentElement.querySelector('.swrve-event-button').addEventListener('click', function() {
            window.plugins.swrve.event("helo.from.phonegap", undefined, function() {
                window.plugins.toast.showShortTop("Event queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: event not queued");
            });
        });

        parentElement.querySelector('.swrve-event-payload-button').addEventListener('click', function() {
            window.plugins.swrve.event("helo.from.phonegap", {"test":"payload"}, function() {
                window.plugins.toast.showShortTop("Event with payload queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: event with payload not queued");
            });
        });
        parentElement.querySelector('.swrve-update-button').addEventListener('click', function() {
            window.plugins.swrve.userUpdate({"phonegap": "TRUE"}, function() {
                window.plugins.toast.showShortTop("User update queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: user update not queued");
            });
        });
        parentElement.querySelector('.swrve-currency-given').addEventListener('click', function() {
            window.plugins.swrve.currencyGiven("Gold", 20, function() {
                window.plugins.toast.showShortTop("Currency given queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: currency given not queued");
            });
        });
        parentElement.querySelector('.swrve-purchase').addEventListener('click', function() {
            window.plugins.swrve.purchase("your.item", "Gold", 2, 15, function() {
                window.plugins.toast.showShortTop("Purchase queued");
            }, function () {
                window.plugins.toast.showShortTop("Error: purchase not queued");
            });
        });
        if (window.plugins.swrve.android) {
            // Android unvalidated IAP
            parentElement.querySelector('.swrve-iap').addEventListener('click', function() {
                window.plugins.swrve.iap(2, "your.item", 2.99, "USD", function() {
                    window.plugins.toast.showShortTop("IAP queued");
                }, function () {
                    window.plugins.toast.showShortTop("Error: IAP not queued");
                });
            });
        } else {
            // iOS unvalidated IAP
            parentElement.querySelector('.swrve-iap').addEventListener('click', function() {
               window.plugins.swrve.unvalidatedIap(99.2, "USD", "iap_item", 2, function() {
                  window.plugins.toast.showShortTop("Unvalidated IAP queued");
               }, function () {
                  window.plugins.toast.showShortTop("Error: IAP not queued");
               });
            });
        }
        parentElement.querySelector('.swrve-send-events-button').addEventListener('click', function() {
            window.plugins.swrve.sendEvents(function() {
                window.plugins.toast.showShortTop("Event queue sent to Swrve");
            }, function () {
                window.plugins.toast.showShortTop("Error: event queue not sent");
            });
        });
        parentElement.querySelector('.swrve-resources-button').addEventListener('click', function() {
            window.plugins.swrve.getUserResources(function(resources) {
                // JSON object containing the resources
                window.plugins.toast.showShortTop(JSON.stringify(resources));
            }, function () {
                window.plugins.toast.showShortTop("Error: could not get resources");
            });
        });
        parentElement.querySelector('.swrve-resources-diff-button').addEventListener('click', function() {
            window.plugins.swrve.getUserResourcesDiff(function(resourcesDiff) {
                // JSON object containing the resources
                window.plugins.toast.showShortTop(JSON.stringify(resourcesDiff));
            }, function () {
                window.plugins.toast.showShortTop("Error: could not get resources diff");
            });
        });
    }
};
