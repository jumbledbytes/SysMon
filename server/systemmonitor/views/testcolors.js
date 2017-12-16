
var config = {};
var db = {};

var noColor, colorFail, colorHalf, colorPass;

var configure = function(appConfig) {
    var testSchema = {
        score: "Number",
        color: "String"
    }
    
    config = appConfig;
    db = config.storage.instance;
    db.loadSchema("colors", testSchema);
    loadDefaultColors();
}

var loadDefaultColors = function() {
    noColor = {
        score: -1,
        color: "#DDDDDDFF"
    }
    colorFail = {
        score: 0,
        color: "#FF3300"
    }
    colorFair = {
        score: 50,
        color: "#FFFF00"
    }
    colorPass = {
        score: 100,
        color: "#00DD00"
    }
    db.clear("colors");
    db.save("colors", noColor);
    db.save("colors", colorFail);
    db.save("colors", colorHalf);
    db.save("colors", colorPass);
}

var getColors = function() {
    return [noColor, colorFail, colorFair, colorPass];
}

module.exports = {
    configure: configure,
    getColors: getColors
}