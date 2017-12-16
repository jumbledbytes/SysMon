var drivers = {}
drivers['apns'] = require("./notifications/apns");

var notifiers = [];

var hostStatus = {};
var acknowledgedDevices = {};
var passingScore = 25;
var maxNotificationLength = 140;

var configure = function(appConfig) {
    config = appConfig;
    if(config.notifications) {
        config.notifications.forEach(function(notification) {
            if(! drivers[notification.driver]) {
                console.error("No notification driver defined for: " + notification.driver);
                return;
            }
            console.log("Loading " + notification.driver + " notification driver");
            var instance = drivers[notification.driver];
            notifiers.push(instance);
            appConfig.notifiers.push(instance);
            instance.configure(appConfig);
        })
    }
    
}

var saveDeviceToken = function(deviceName, deviceToken) {
    notifiers.forEach(function(notifier, index) {
        notifier.saveDeviceToken(deviceName, deviceToken);
    });
    acknowledgedDevices[deviceName] = deviceToken;
    
}

var sendNotification = function(message, ignoreDevices) {
    notifiers.forEach(function(notifier, index) {
        notifier.sendNotification(message, ignoreDevices);
    });
}

var processResults = function(systests) {
    var results = systests.getResults("", function(results) {
        var failReport = [];
        var passingReport = [];
        for(testProtocol in results) {
            var testResults = results[testProtocol];
            if(testResults.constructor === Array) {
                testResults.forEach(function(testResult) {
                    var identifier = testProtocol + "://" + testResult.host;
                    if(! hostStatus[identifier]) {
                        hostStatus[identifier] = {}
                    }
                    if(testResult && testResult.test_score < passingScore) {
                        failReport.push(identifier);
                        if(hostStatus[identifier].status == "passed") {
                            // unset acknowledgements when a new failure occurs
                            acknowledgedDevices = {};
                        }
                        hostStatus[identifier].status = "failed";
                    } else {
                        // When failed server comes back online send notification that server is up
                        if(hostStatus[identifier].status == "failed") {
                            passingReport.push(identifier);
                            acknowledgedDevices = {};
                        }
                        
                        // Unset acknowledgements once a test passes
                        hostStatus[identifier].status == "passed"
                    }
                })
            }
        }
    
        // Send notification to devices that haven't acknowledged yet
        var failCount = failReport.length;
        var failString = "The following hosts are down: " + failReport.join(", ");
        if(failString.length > maxNotificationLength) {
            failString = "Warning: " + failCount + " servers or services are not responding";
        }
        if(failCount > 0) {
            sendNotification(failString, acknowledgedDevices);
        }
        
        // When services come back online send notification
        var newPassCount = passingReport.length;
        var passString = "The following hosts are back up: " + passingReport.join(", ");
        if(passString.length > maxNotificationLength) {
            passString = "" + failCount + " servers or services are back up";
        }
        if(newPassCount > 0) {
            sendNotification(passString, {});
        }
    })
}

module.exports = {
    configure: configure,
    notifiers: notifiers,
    saveDeviceToken: saveDeviceToken,
    sendNotification: sendNotification,
    processResults: processResults
}