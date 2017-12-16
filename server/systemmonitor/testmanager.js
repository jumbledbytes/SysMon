
var protocols = require("./protocols");
var storage = require("./storage");
var servers = require("./servers");
var version = require("./version");
var notifications = require('./notifications');
var systests = {};

var config = {}



var configure = function(appConfig, aSystests) {
    config = appConfig;
    systests = aSystests;
    
    servers.configure(config);
    protocols.configure(config);
    notifications.configure(config);
    
    config.systests = systests;
    config.protocols = protocols;
    config.servers = servers;
    config.notifications = notifications;
    
}

var getVersion = function() {
    var result = {
        server_version: version.getVersion(),
        api_version: version.getApiVersion()
    }
    return version;
}

var getConfig = function() {
    return config;
}

var getSysTests = function() {
    return systests;
}

var getServers = function() {
    return servers;
}

var getProtocols = function() {
    return protocols;
}

var getNotifications = function() {
    return notifications;
}

var load = function(loadType, loadParams, loadCallback) {
   var response;
   switch(loadType) {
       case 'test':
        console.log("Loading test: " + loadParams);
        response = systests.loadTest(loadParams)
        break;
       case 'server':
        response = systests.loadServers(loadParams);
        break;
   }
   if(typeof loadCallback === "function") {
       loadCallback(response);
   }
}

var run = function(action, param, resultCallback) {
   var response = "";
   switch(action) {
       case 'test':
        systests.runTest(param);
        response = "Test Started";
        break;
   }
   if(typeof loadCallback === "function") {
       loadCallback(response);
   }
}

var get = function(type, param, resultCallback) {
   var response;
   switch(type) {
       case 'test':
        systests.getTests(param, resultCallback);
        break;
       case 'results':
        systests.getResults(param, resultCallback);
        break;
       case 'history':
        systests.getHistory(param, resultCallback);
        break;
       case 'status':
        servers.getStatus(protocol, param, resultCallback);
        break;
       case 'hosts':
        servers.getServers(resultCallback);
        break;
       default:         
        break
   }
}

var startTests = function(updateInterval) {
    setInterval(function() {
        // TODO: only run tests at their test defined intervals
        console.log("RUNNNING TESTS!!!!!!!!!!");
        systests.runTest();
    }, updateInterval * 1000);
}

var enableNotifications = function() {
    // TODO: define this dynamically
    var passingScore = 25;
    
    var notificationInterval = 60;
    var maxNotificationLenght = 80;
    
    notifications.processResults(systests);
    setInterval(function() {
        notifications.processResults(systests);
    }, notificationInterval * 1000);
}

module.exports = {
    configure: configure,
    getConfig: getConfig,
    getSysTests: getSysTests,
    getServers: getServers,
    getProtocols: getProtocols,
    getNotifications: getNotifications,
    enableNotifications: enableNotifications,
    load: load,
    run: run,
    get: get,
    startTests: startTests
};
