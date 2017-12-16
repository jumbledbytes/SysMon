


var hosts = {};
var config = {};
var port = 443;
var db = {};

var configure = function(appConfig) {
    config = appConfig;
    db = config.storage.instance;
}

var test = function(hosts) {
    var options = {
        host: "sysmon.host",
        port: port,
        path: '/',
        method: 'GET'
    };

    var req = https.request(options, function(res) {
        console.log(res.statusCode);
        res.on('data', function(d) {
            processResults(d);
        });
    });
    req.end();

    req.on('error', function(e) {
        console.error(e);
    });
}

var processResults = function(results) {
    // TODO: Parse results from sysmon and save them
}

module.exports = {
    configure: configure,
    test: test
}
