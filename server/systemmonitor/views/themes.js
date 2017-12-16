
var config = {};
var db = {};
var colors = require("./testcolors")

var configure = function(appConfig) {
    config = appConfig;
    db = config.storage.instance;
    colors.configure(appConfig);
}

var getTestColors = function() {
    return colors.getColors();
}

var getTheme = function() {
    var theme = {
        theme_name: "Default",
        test_colors: getTestColors()
    }
    return theme;
}

module.exports = {
    configure: configure,
    getTheme: getTheme,
    getTestColors: getTestColors
}