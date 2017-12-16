var express = require('express');
var https = require('https');
var router = express.Router();
var httpAuth = require('http-auth');

var basicAuth = httpAuth.basic({
        realm: "Web."
    }, function (username, password, callback) { 
        // TODO: password backend
        callback(username === "user" && password === "pass");
    }
);
var auth = httpAuth.connect(basicAuth);


var themes = require("../views/themes.js");
var version = require("../version.js");
var testManager = {}

getRouter = function() {
    return router;
}

setAuthentication = function(newAuth) {
    auth = newAuth;
}

// Example functions that operate on web sockets
sendObject = function(type, obj, req) {
    var sendCount = 0;
    // Send the object to all connected clients
    for (clientSocket in req.app.locals.clients) {
        clientSocket.emit(type, obj);
        sendCount = sendCount + 1;
    }
    return sendCount;
}

router.configure = function(config, aTestManager) {
    testManager = aTestManager;
    router.config = config;
    themes.configure(config);
    
}


router.get('/version', function(req, res) {
    console.log("Request for version");
    var result = {
        server_version: version.getVersion(),
        api_version: version.getApiVersion()
    }
    res.json(result);
});


/* Non-WebSocket RESTful API */
router.get('/config', auth, function(req, res) {
    res.json(req.app.settings.config);
});

router.get('/status/:protocol/:host', auth, function(req, res) {
    var protocol = req.params.protocol;
    var host = req.params.host;
    var servers = testManager.getServers();
    servers.getStatus(protocol, [host], function(results) {
        res.json(results);
    });
});

router.get('/history/:protocol/:host/:duration?', auth, function(req, res) {
    var protocol = req.params.protocol;
    var host = req.params.host;
    var servers = testManager.getServers();
    var duration = req.params.duration;
    if(! duration) {
        duration = 24 * 60 * 60; // one day woth of seconds
    }
    servers.getHistory(protocol, [host], duration, function(results) {
        res.json(results);
    });
});

router.get('/test/:protocol/:host', auth, function(req, res) {
    var protocol = req.params.protocol;
    var host = req.params.host;
    var protocols = testManager.getProtocols();
    res.json(protocols[protocol].test([host]));
});

router.get('/load/:type/:param1', auth, function(req, res) {
   var type = req.params.type;
   var systests = testManager.getSysTests();
   var response;
   switch(type) {
       case 'test':
        console.log("Loading test: " + req.params.param1);
        response = systests.loadTest(req.params.param1)
        break;
       case 'server':
        response = systests.loadServers(req.params.param1);
        break;
   }
   res.json(response);
});

router.get('/run/:action/:param1?', auth, function(req, res) {
   var action = req.params.action;
   var response = "";
   var systests = testManager.getSysTests();
   switch(action) {
       case 'test':
        systests.runTest(req.params.param1);
        response = "Test Started";
        break;
   }
   res.json(response);
});

router.get('/save/:action/:param1*?/:param*2?', auth, function(req, res) {
   var action = req.params.action;
   var response = "";
   var notifications = testManager.getNotifications();
   switch(action) {
       case 'devicetoken':
        notifications.saveDeviceToken(req.params.param1, req.params.param2);
        response = "Test Started";
        break;
   }
   res.json(response);
});

router.get('/show/:type/:param1?/:param2?', auth, function(req, res) {
   var type = req.params.type;
   var response;
   var systests = testManager.getSysTests();
   switch(type) {
       case 'test':
        systests.getTests(req.params.param1, function(testData) {
            res.json(testData);
        })
        break;
       case 'results':
        systests.getResults(req.params.param1, function(testResults) {
            res.json(testResults);
        })
        break;
       case 'history':
        systests.getHistory(req.params.param1, req.params.paran2, function(testResults) {
            res.json(testResults);
        })
        break;
       case 'theme':
        console.log("Getting theme: " + JSON.stringify(themes.getTheme()));
        res.json(themes.getTheme());
        break;
       default:         
        res.json(response);
   }
});

router.get('/hosts', auth, function(req, res) {
    var servers = testManager.getServers();
    servers.getServers(function(hosts) {
        res.json(hosts);
    });
});

module.exports = {
    getRouter: getRouter,
    setAuthentication: setAuthentication
}
