

var hosts = {};
var config = {};
var port = 80;
var successCode = 200;
var db = {};

var schema = {
    host: "String",
    status_code: "Number",
    test_score: "Number",
    message: "String"
}

var configure = function(appConfig) {
    config = appConfig;
    db = config.storage.instance;
    config["http"].schema = schema;
    db.loadSchema("http", schema);
}

var test = function(hosts) {
    hosts.forEach(function(host, index) {
       testHost(host); 
    });
}

var testHost = function(host) {
    var http = require('http');
    var httpAddress = host;
    if (config.hosts[host]) {
        httpAddress = config.hosts[host];
    }
    var options = {
        host: httpAddress,
        port: port,
        path: '/.well-known/sysmon/test.html'
    };
    
    config.servers.addServer(httpAddress, host)
    http.get(options, function(resp) {
        resp.on('data', function(chunk) {
            var score = 0;
            if(resp.statusCode == successCode) {
                score = 100;
            }
            var success = {
                host: host,
                status_code: resp.statusCode,
                test_score: score,
                message: ""
            }
            db.save("http", success);
        });
    }).on("error", function(e) {
        console.log("Got error: " + e.message);
        var error = {
            host: host,
            status_code: 500,
            message: e.message,
            test_score: 0
        }
        db.save("http", error);
    });
}

module.exports = {
    configure: configure,
    test: test
}
