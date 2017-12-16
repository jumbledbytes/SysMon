
var Imap = require('imap');
var config = {};
var db = {};
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
    if(! config["imaps"]) {
        config["imaps"] = {};
    }
    config["imaps"].schema = schema;
    db = config.storage.instance;
    db.loadSchema("imaps", schema);
}
    
var testHostImap = function(host, name, username, password, port) {
    // TODO: onComplete callback?
    var i = 0;
    var receiveCount = 0;
    var expired = false;
    
    config.servers.addServer(host, name);
    var imapOptions = {
        user: username,
        password: password,
        host: host,
        port: port,
        tls: true
    }
    var imap = new Imap(imapOptions);
 
    function openInbox(cb) {
        imap.openBox('INBOX', true, cb);
    }
    
    var result = {
        host: name,
        message: ""
    };
    imap.once('ready', function() {
        openInbox(function(err, box) {
            if (err) throw err;
            result.test_score = 100;
        });
        imap.end();
    });
    
    imap.once('error', function(err) {
        result.test_score = 0;
        result.message = err.textCode;
    });
    
    imap.once('end', function() {
        db.save("imaps", result);
    });
    
    imap.connect(); 
}

var test = function(hosts, test) {
    hosts.forEach(function(host, index) {
        var imapAddress = host;
        if (config.hosts[host]) {
            imapAddress = config.hosts[host];
        }
        config.servers.addServer(imapAddress, host)
        testHostImap(imapAddress, host, test.username, test.password, test.port);
    })
}

module.exports = {
    configure: configure,
    test: test,
    schema: schema
}
