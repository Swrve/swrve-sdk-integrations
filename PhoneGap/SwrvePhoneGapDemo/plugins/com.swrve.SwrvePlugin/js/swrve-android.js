function SwrvePlugin() {}

SwrvePlugin.prototype.android = true;
SwrvePlugin.prototype.ios = false;

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
// cost is a int
SwrvePlugin.prototype.purchase = function(itemName, currency, quantity, cost, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "purchase", [itemName, currency, quantity, cost]);
};

// quantity is int
// price is float
SwrvePlugin.prototype.iap = function(quantity, product_id, price, currency, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "iap", [quantity, product_id, price, currency]);
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

SwrvePlugin.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.swrve = new SwrvePlugin();
  // Empty callback, override this to listen to custom IAM buttons
  window.swrveCustomButtonListener = function(action) {};
  // Empty callback, override this to listen to push notifications
  window.swrveProcessPushNotification = function(base64Payload) {
    // Decode the base64 encoded string sent by the plugin
    window.swrvePushNotificationListener(JSON.parse(window.atob(base64Payload)));
  };
  window.swrvePushNotificationListener = function(payload) {};
  
  return window.plugins.swrve;
};

cordova.addConstructor(SwrvePlugin.install);
