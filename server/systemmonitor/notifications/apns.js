
var config = {};

var fs = require("fs");
var apn = require('apn');
var apnOptions = { };
var apnConnection ;
var feedback;

var configure = function(appConfig) {
    config = appConfig;


    var privateKey = fs.readFileSync(config["apns"]["key"]);
    var certificate = fs.readFileSync(config["apns"]["cert"]);
    apnOptions["cert"] = certificate;
    apnOptions["key"] = privateKey
    apnConnection = new apn.Connection(apnOptions);
    feedback = new apn.Feedback(apnOptions);
    
    feedback.on("feedback", function(devices) {
        devices.forEach(function(item) {
            console.log("Got feedback for device: " + item.device);
            // Do something with item.device and item.time;
        })
    });
    
    var apnsSchema = {
        device_name: "String",
        device_token: "String"
    }
    var db = config.storage.instance;
    db.loadSchema("apns", apnsSchema);

}

var saveDeviceToken = function(deviceName, deviceToken) {
    var tokenData = {
        device_name: deviceName,
        device_token: deviceToken
    }
    var db = config.storage.instance;
    db.save('apns', tokenData, {device_name: deviceName});
}

var sendNotification = function(message, ignoreRecipients) {
    var notification = new apn.Notification();

    notification.expiry = Math.floor(Date.now() / 1000) + 3600 * 3; // Expires 3 hour from now.
    notification.badge = 1;
    notification.sound = "ping.aiff";
    notification.alert = message;
    notification.payload = {'servers': 'server'};
    
    var db = config.storage.instance;
    
    db.get("apns", {}, false, function(results) {
        console.log("APNS Results: " + JSON.stringify(results));
        results.forEach(function(deviceInfo) {
            
            var device = new apn.Device(deviceInfo.device_token);
            var sendToDevice = true;
            if(ignoreRecipients) {
                for(var recipient in ignoreRecipients) {
                    var safeRecipient = recipient.replace("'", "");
                    if(safeRecipient == deviceInfo.device_name) {
                        sendToDevice = false;
                    }
                }
            }
            if(sendToDevice) {
                apnConnection.pushNotification(notification, device);
                console.log("Sending notification to: " + deviceInfo.device_token)
            }
        })
        
    })
}

module.exports = {
    configure: configure,
    sendNotification: sendNotification,
    saveDeviceToken: saveDeviceToken
}