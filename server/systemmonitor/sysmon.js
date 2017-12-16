var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var fs = require("fs");
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var https = require('https');
var app = express();
var index = require('./routes/index');
var config = JSON.parse(fs.readFileSync('./config/config.json', 'utf8'));
var storage = require('./storage');
var testManager = require('./testmanager');
var sysTests = require('./systests');
var routes = index.getRouter();

// Parse command line params
var version = require('./version')
var params = require('commander');
var serverPort = 7588;
var testInterval = config["test_interval"];
var testName = "systest";
var sendNotifications = true;

params
  .version(version.getVersion())
  .option('-t, --test <test_name>', 'Name of test, or url of test, to load and run (Default: '+testName+')')
  .option('-i, --interval <seconds>', 'Minimum testing interval (Default: '+testInterval+' seconds)')
  .option('-p, --port <port_number>', 'Port server listens on (Default: '+ String(serverPort) +')')
  .option('-q, --quiet', 'Disable notifications')
.parse(process.argv);

if(params.port) {
    serverPort = params.port;
}
if(params.interval) {
    testInterval = params.interval;
}
if(params.test) {
    testName = params.test;
}
if(params.quiet) {
    sendNotifications = false;
}

console.log("Loading test: " + testName);
if(typeof testInterval === "undefined" || testInterval == 0) {
    testInterval = 300; // default to 5 minutes
}
// Start the http server

var privateKey = fs.readFileSync('../certs/key.pem');
var certificate = fs.readFileSync('../certs/cert.pem');
var options = {
    key: privateKey,
    cert: certificate,
    ciphers: 'ECDHE-RSA-AES256-SHA:AES256-SHA:RC4-SHA:RC4:HIGH:!MD5:!aNULL:!EDH:!AESGCM',
    honorCipherOrder: true
};
credentials = {key: privateKey, cert: certificate};
var server = https.createServer(options, app).on('error', function(err) {
    console.log("HTTPS socket error: " + err);
});
server.listen(serverPort);

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.set('config', config);

storage.configure(config);
sysTests.configure(config);
testManager.configure(config, sysTests);
routes.configure(config, testManager);

testManager.load('test', testName);
testManager.startTests(testInterval);
if(sendNotifications) {
    testManager.enableNotifications();
}

// uncomment after placing your favicon in /public
//app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', routes);

// catch 404 and forward to error handler
/*app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});*/

app.use(function(req, res, next) {
    //res.locals.clients = clients;
    //res.locals.io = io;
    next();
});

// error handlers

// development error handler
// will print stacktrace

/*
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        });
    });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    console.error(err.message);
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: {}
    });
});
*/


module.exports = app;


