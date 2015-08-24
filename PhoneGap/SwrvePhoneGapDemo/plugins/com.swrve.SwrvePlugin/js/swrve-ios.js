function SwrvePlugin() {}

SwrvePlugin.prototype.android = false;
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
  return window.plugins.swrve;
};

cordova.addConstructor(SwrvePlugin.install);
