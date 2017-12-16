
var config, db;
var serverNames = {};
var fs = require("fs");

var configure = function(appConfig) {
    var hostSchema = {
        host: "String",
        nick_name: "String",
        update_time: "Integer"
    }
    config = appConfig;
    config.servers = this;
    db = config.storage.instance;
    db.loadSchema("servers", hostSchema);
}

var addServer = function(serverName, nickName) {
    var currentTime = new Date().getTime() * 1000;
    if(! nickName) {
        nickName = serverName;
    }
    var hostData = {
        host: serverName,
        nick_name: nickName,
        update_time: parseInt(currentTime)
    }
    db.save("servers", hostData, {host: serverName});
}

var loadServers = function(serverConfig) {
    serverNames = JSON.parse(fs.readFileSync('./config/'+serverConfig+'.json', 'utf8'));
    return serverNames;
}

var getServers = function(callback) {
    if(typeof callback !== "function") {
        return; 
    }
    db.get("servers", {}, true, callback);
}

var getServerData = function(table, hosts, duration, callback) {
    var resultQuery = { host: [] }
    hosts.forEach(function(host, index) {
        resultQuery.host.push(host);
    });
    
    db.get(table, resultQuery, duration, callback);
}

var getStatus = function(table, hosts, callback) {
    if(typeof callback !== "function") {
        return;
    }
    getServerData(table, hosts, true, callback);
}

var getHistory = function(table, hosts, duration, callback) {
    if(typeof callback !== "function") {
        return;
    }
    getServerData(table, hosts, duration, callback);
}

module.exports = {
    configure: configure,
    addServer: addServer,
    loadServers: loadServers,
    getServers: getServers,
    getStatus: getStatus,
    getHistory: getHistory
};