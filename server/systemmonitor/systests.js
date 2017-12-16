
var config = {};
var db = {};
var fs = require("fs");

var configure = function(appConfig) {
    var testSchema = {
        test_name: "String",
        protocol: "String",
        group_name: "String",
        host: "String",
        username: "String",
        password: "String",
        port: "Number",
        test_interval: "Number",
        notification_threshold: "Number"
    }
    
    config = appConfig;
    db = config.storage.instance;
    db.loadSchema("tests", testSchema);
}

var addTest = function(testName, protocol, group, host, testInterval, username, password, port) {
    var test = {
        test_name: testName,
        protocol: protocol,
        group_name: group,
        host: host,
        test_interval: testInterval,
        username: username,
        password: password,
        port: port
    }
    config.servers.addServer(host);
    db.save("tests", test);
}

var loadTests = function(tests) {
    tests.forEach(function(test, index) {
        var username = "";
        var password = "";
        var port = 0;
        if(test.username) { username = test.username; }
        if(test.password) { password = test.password; }
        if(test.port) { port = test.port; }
        addTest(test.test_name, test.protocol, test.group, test.host, test.test_interval, username, password, port);
    });
}

var isURL = function(str) {
  var pattern = new RegExp('^(https?:\\/\\/)?'+ // protocol
  '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.?)+[a-z]{2,}|'+ // domain name
  '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
  '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
  '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
  '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
  return pattern.test(str);
}

var getTestFromUrl = function(testUrl) {
    var https = require('https');
    https.get(testUrl, (res) => {
        // consume response body
        res.on('data', function(testData) {
            var tests = JSON.parse(testData.toString('utf-8'))
            processTestData(tests);
        });
        res.resume();
    }).on('error', (e) => {
        console.log(`Got error: ${e.message}`);
    });
}

var processTestData = function(testData) {
     // Remove old test definitions
    var testNames = {};
    testData.forEach(function(value, index) {
        if(value.test_name) {
            testNames[value.test_name] = true;
        }
    });
    for(testName in testNames) {
        db.clear("tests", {test_name: testName});
    }
    
    // Add new test definitions
    loadTests(testData);
    
    return testData;
}

var loadTest = function(testName) {
    var testData;
    try {
        testData = JSON.parse(fs.readFileSync('./systests/'+testName+'.json', 'utf8'));
        processTestData(testData);
    } catch(err) {
        console.log("WARNING: Unable to load test file: " + testName)
        testData = undefined;
    }
    
    // attempt to load from remote URL
    if(!testData && isURL(testName)) {
        getTestFromUrl(testName);
    } 
}

var getTests = function(testName, callback) {
    if(testName) {
        db.get("tests", {test_name: testName}, false, callback);
    } else {
        db.get("tests", {}, false, callback);
    }
}

var runTest = function(testName, callback) {
    getTests(testName, function(tests) {
       tests.forEach(function(test, index) {
           var protocol = test.protocol;
           var host = test.host;
           config.protocols[protocol].test([host], test);
       })
       if(typeof callback === "function") {
           callback();
       }
    });
}

var getResults = function(testName, callback) {
    if (typeof callback !== "function") {
        return;
    }
    getTests(testName, function(tests) {
        var results = { test_name: testName};
        var testCount = 0;
        tests.forEach(function(test, index) {
           config.servers.getStatus(test.protocol, [test.host], function(testStatus) {
               if(! results[test.protocol]) {
                   results[test.protocol] = [];
               }
               testStatus.forEach(function(status, index) {
                   results[test.protocol].push(status);
               })
               testCount = testCount + 1;
               if(testCount === tests.length) {
                   callback(results);
               }
           })
        }) 
    });
}

var getHistory = function(duration, testName, callback) {
    if (typeof callback !== "function") {
        return;
    }
    if(typeof duration === "undefined") {
        duration = 24 * 60 * 60 // one day worth of seconds
    }
    getTests(testName, function(tests) {
        var results = { test_name: testName};
        var testCount = 0;
        tests.forEach(function(test, index) {
           config.servers.getHistory(test.protocol, [test.host], duration, function(testStatus) {
               if(! results[test.protocol]) {
                   results[test.protocol] = [];
               }
               testStatus.forEach(function(status, index) {
                   results[test.protocol].push(status);
               })
               testCount = testCount + 1;
               if(testCount === tests.length) {
                   callback(results);
               }
           })
        }) 
    });
}

module.exports = {
    configure: configure,
    addTest: addTest,
    loadTests: loadTests,
    loadTest: loadTest,
    getTests: getTests,
    runTest: runTest,
    getResults: getResults,
    getHistory: getHistory
}