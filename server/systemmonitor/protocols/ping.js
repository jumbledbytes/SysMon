
// need to successfully run npm install net-ping for this to work
var netPing = require("net-ping");
var pingSession = netPing.createSession();
var config = {};
var db = {};
//{ "type":"ping", "servers":[{"name":"ojo",
//"results":{"connection":"good",
//"sent":5,"received":5,"ttl":{"min":0.326,"avg":0.693,"max":1.788,"mdev":0.553}},...]},
var schema = {
    host: "String",
    connection: "String",
    sent: "Number",
    received: "Number",
    min: "Number",
    avg: "Number",
    max: "Number",
    mdev: "Number",
    test_score: "Number",
    message: "String"
}

var configure = function(appConfig) {
    config = appConfig;
    config["ping"].schema = schema;
    db = config.storage.instance;
    db.loadSchema("ping", schema);
}
    
var pingHost = function(host, name) {
    // TODO: onComplete callback?
    var i = 0;
    var receiveCount = 0;
    var expired = false;
    
    config.servers.addServer(host, name);
    
    // After 1 second save the number of ping responses received
    setTimeout(function(){
        var results;
        var score = 0;
        if(config.ping.ping_count > 0) {
            score = (receiveCount / config.ping.ping_count) * 100;
        }
        expired = true;
        
        results = {
            host: name,
            sent: config.ping.ping_count,
            received: receiveCount,
            test_score: score
        }
        db.save("ping", results);
    }, 1000);  
    
    do {
        pingSession.pingHost(host, function(error, target) {
            if (!error) {
                if(! expired) {
                    receiveCount = receiveCount + 1;
                }
            } else {
                console.log("Ping error from " + host + ": " + error);
            }
        });
        i = i + 1;
    } while(i<config.ping.ping_count)
}

var test = function(hosts) {
    hosts.forEach(function(host, index) {
        var pingAddress = host;
        if (config.hosts[host]) {
            pingAddress = config.hosts[host];
        }
        config.servers.addServer(pingAddress, host)
        pingHost(pingAddress, host);
    })
}

module.exports = {
    configure: configure,
    test: test,
    schema: schema
}
