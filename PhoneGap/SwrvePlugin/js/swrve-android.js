function SwrvePlugin() {}

SwrvePlugin.prototype.android = true;
SwrvePlugin.prototype.ios = false;

// name is a string
// payload is a JSON object
SwrvePlugin.prototype.event = function(name, payload, success, fail) {
  if (payload == undefined || !payload || payload.length < 1) {
    return cordova.exec(success, fail, "SwrvePlugin", "event", [name]);
  } else {
    return cordova.exec(success, fail, "SwrvePlugin", "event", [name, payload]);
  }
};

// attributes is a JSON object
SwrvePlugin.prototype.userUpdate = function(attributes, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "userUpdate", [attributes]);
};

// currency is a string
// quantity is an int
SwrvePlugin.prototype.currencyGiven = function(currency, quantity, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "currencyGiven", [currency, quantity]);
};

// itemName is a string
// currency is a string
// quantity is an int
// cost is a double
SwrvePlugin.prototype.purchase = function(itemName, currency, quantity, cost, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "purchase", [itemName, currency, quantity, cost]);
};

// quantity is an int
// productId is a string
// price is double
// currency is a string
SwrvePlugin.prototype.iap = function(quantity, productId, price, currency, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "iap", [quantity, productId, price, currency]);
};

// productId is a string
// productPrice is a double
// currency is a string
// purchaseData is a string
// dataSignature is a string
SwrvePlugin.prototype.iapPlay = function(productId, productPrice, currency, purchaseData, dataSignature, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "iapPlay", [productId, productPrice, currency, purchaseData, dataSignature]);
};

SwrvePlugin.prototype.sendEvents = function(success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "sendEvents", []);
};

SwrvePlugin.prototype.getUserResources = function(success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "getUserResources", []);
};

SwrvePlugin.prototype.getUserResourcesDiff = function(success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "getUserResourcesDiff", []);
};

SwrvePlugin.prototype.refreshCampaignsAndResources = function(success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "refreshCampaignsAndResources", []);
};

SwrvePlugin.prototype.resourcesListenerReady = function() {
  return cordova.exec(undefined, undefined, "SwrvePlugin", "resourcesListenerReady", []);
};

SwrvePlugin.prototype.setResourcesListener = function(listener) {
  window.swrveResourcesUpdatedListener = listener;
  window.plugins.swrve.resourcesListenerReady();
};

SwrvePlugin.prototype.setCustomButtonListener = function(listener) {
  window.swrveCustomButtonListener = listener;
};

SwrvePlugin.prototype.pushNotificationListenerReady = function() {
  return cordova.exec(undefined, undefined, "SwrvePlugin", "pushNotificationListenerReady", []);
};

SwrvePlugin.prototype.setPushNotificationListener = function(listener) {
  window.swrvePushNotificationListener = listener;
  window.plugins.swrve.pushNotificationListenerReady();
};

SwrvePlugin.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.swrve = new SwrvePlugin();
  // Empty callback for new user resources
  window.swrveResourcesUpdatedListener = function(resources) {};
  window.swrveProcessResourcesUpdated = function(resourcesJson) {
    // Decode the base64 encoded string sent by the plugin
    window.swrveResourcesUpdatedListener(JSON.parse(window.atob(resourcesJson)));
  };
  // Empty callback, override this to listen to custom IAM buttons
  window.swrveCustomButtonListener = function(action) {};
  // Empty callback, override this to listen to push notifications
  window.swrvePushNotificationListener = function(payload) {};
  window.swrveProcessPushNotification = function(base64Payload) {
    // Decode the base64 encoded string sent by the plugin
    window.swrvePushNotificationListener(JSON.parse(window.atob(base64Payload)));
  };
  
  return window.plugins.swrve;
};

cordova.addConstructor(SwrvePlugin.install);
