var ping = require("./protocols/ping");
var http = require("./protocols/http");
var imaps = require("./protocols/imaps");
var dns = require('./protocols/dns');
var smtp = require('./protocols/smtp');
var pop3 = require('./protocols/pop3');

var configure = function(appConfig) {
    ping.configure(appConfig);
    http.configure(appConfig);
    imaps.configure(appConfig);
    dns.configure(appConfig);
    smtp.configure(appConfig);
    pop3.configure(appConfig);
}

module.exports = {
    configure: configure,
    ping: ping,
    http: http,
    imaps: imaps,
    dns: dns,
    smtp: smtp,
    pop3: pop3
};
