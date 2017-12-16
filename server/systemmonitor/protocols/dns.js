


var dns = require('dns');
var config = {};
var db = {};
var testInProgress = false;

var resolveServer = "8.8.8.8";

var schema = {
    host: "String",
    test_score: "Number",
    message: "String"
}

var configure = function(appConfig) {
    config = appConfig;
    if(! config["dns"]) {
        config["dns"] = {};
    }
    config["dns"].schema = schema;
    db = config.storage.instance;
    db.loadSchema("dns", schema);
}
    
var testServers = function(servers, testCallback) {
    // dns.setServers is not thread safe make sure that 
    // it is only being modified
    if(! testInProgress) {
        testInProgress = true;
        dns.setServers(servers);
        setTimeout(function() {
            // delay a little to let allow dns.setServers to finish
            // this is hack to try to work around crash in c-ares 
            testCallback();
            testInProgress = false;
        }, 500);
    } else {
        while(testInProgress) {
            setTimeout(function() {
                
            }, 20);
        }
        testInProgress = true;
        dns.setServers(servers);
        setTimeout(function() {
            // delay a little to let allow dns.setServers to finish
            // this is hack to try to work around crash in c-ares 
            testCallback();
            testInProgress = false;
        }, 500);
    }
}
    
var testHostDNS = function(host, name) {
    // first we have to resolve the "host" we are checking since
    // setServers only takes IP addresses
    var result = {
        host: name,
        test_score: 0,
        message: ""
    }
    
    dns.lookup(host, (hostError, addresses, family) => {
        if(hostError) {
            result.message = hostError.message;
            db.save('dns', result);
        } else {
            testServers([addresses], function() {
                dns.resolve(resolveServer, function(error, addresses) {
                    if(error) {
                        result.message = error.message;
                    } else if(addresses.length > 0) {
                        result.test_score = 100;
                    } else {
                        result.message = resolveServer + " did not resolve";
                    }
                    db.save("dns", result);
                });
            });
        }
    });
}

var test = function(hosts, test) {
    hosts.forEach(function(host, index) {
        var dnsAddress = host;
        if (config.hosts[host]) {
            dnsAddress = config.hosts[host];
        }
        config.servers.addServer(dnsAddress, host)
        testHostDNS(dnsAddress, host);
    })
}

module.exports = {
    configure: configure,
    test: test,
    schema: schema
}
