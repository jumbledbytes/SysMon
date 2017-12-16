var drivers = {}
drivers['sqlite'] = require("./storage/sqlite");

var instance = {}

var configure = function(appConfig) {
    if(! drivers[appConfig.storage.driver]) {
        console.error("No storage driver defined for: " + appConfig.storage.driver);
        return;
    }
    console.log("Loading " + appConfig.storage.driver + " storage driver");
    instance = drivers[appConfig.storage.driver];
    appConfig.storage.instance = instance;
    instance.configure(appConfig);
}

module.exports = {
    configure: configure,
    instance: instance
}