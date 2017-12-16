
var pop3 = require('poplib');
var config = {};
var db = {};
var protocolName = "pop3";
//{ "type":"ping", "servers":[{"name":"ojo",
//"results":{"connection":"good",
//"sent":5,"received":5,"ttl":{"min":0.326,"avg":0.693,"max":1.788,"mdev":0.553}},...]},
var schema = {
    host: "String",
    test_score: "Number",
    message: "String"
}

var configure = function(appConfig) {
    config = appConfig;
    if(! config[protocolName]) {
        config[protocolName] = {};
    }
    config[protocolName].schema = schema;
    db = config.storage.instance;
    db.loadSchema(protocolName, schema);
}
    
var testHostPop3 = function(host, name, username, password, port) {
   var client = new pop3(port, host, {
        tlserrs: false,
        enabletls: true,
        debug: false
    });
    
    var result = {
        host: name,
        test_score: 0,
        message: ""
    }
    
    client.on("error", function(error) {
        result.message = error;
        result.test_score = 0;
        db.save(protocolName, result);

    });

    client.on("connect", function() {
        client.login(username, password);
    });
    
    client.on("login", function(status, rawdata) {
        if (status) {
            result.test_score = 100;
            result.message = "";
            client.quit();
        } else {
            result.test_score = 0;
            result.message = "Login failed";
            client.quit();
        }
        db.save(protocolName, result);
    });
}

var test = function(hosts, test) {
    hosts.forEach(function(host, index) {
        var popAddress = host;
        if (config.hosts[host]) {
            popAddress = config.hosts[host];
        }
        config.servers.addServer(popAddress, host)
        testHostPop3(popAddress, host, test.username, test.password, test.port);
    })
}

module.exports = {
    configure: configure,
    test: test,
    schema: schema
}
