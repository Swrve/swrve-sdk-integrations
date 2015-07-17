var SwrvePlugin = function() {}

SwrvePlugin.prototype.ios = true;

// parameters is a JSON object
SwrvePlugin.prototype.event = function(name, parameters, success, fail) {
  if (!parameters || parameters.length < 1) {
    return cordova.exec(success, fail, "SwrvePlugin", "event", [name]);
  } else {
    return cordova.exec(success, fail, "SwrvePlugin", "event", [name, parameters]);
  }
};

// parameters is a JSON object
SwrvePlugin.prototype.userUpdate = function(parameters, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "userUpdate", [parameters]);
};

// quantity is an int
SwrvePlugin.prototype.currencyGiven = function(currency, quantity, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "currencyGiven", [currency, quantity]);
};

// quantity is an int
// cost is a int
SwrvePlugin.prototype.purchase = function(name, currency, quantity, cost, success, fail) {
  return cordova.exec(success, fail, "SwrvePlugin", "purchase", [name, currency, quantity, cost]);
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

if (!window.plugins) {
  window.plugins = {};
}
if (!window.plugins.swrve) {
  window.plugins.swrve = new SwrvePlugin();
}

module.exports = SwrvePlugin;
