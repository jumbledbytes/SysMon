var nodemailer = require('nodemailer');
var config = {};
var db = {};

var schema = {
    host: "String",
    test_score: "Number",
    message: "String"
}

var configure = function(appConfig) {
    config = appConfig;
    db = config.storage.instance;
    db.loadSchema("smtp", schema);
}

var test = function(hosts, test) {
   hosts.forEach(function(host, index) {
        var smtpAddress = host;
        if (config.hosts[host]) {
            smtpAddress = config.hosts[host];
        }
        config.servers.addServer(smtpAddress, host)
        testHostSmtp(smtpAddress, host, test.username, test.password, test.port);
    })
}

var testHostSmtp = function(host, name, username, password, port) {

    // create reusable transporter object using the default SMTP transport
    var transporter = nodemailer.createTransport({
        host: host,
        port: port,
        service: 'smtp',
        secure: false,
        auth: {
            user: username,
            pass: password,
        },
        authMethod: 'LOGIN',
        requireTLS: true
    });

    // setup e-mail data with unicode symbols
    var mailOptions = {
        from: '"sysmon 👥" <'+username+'>', // sender address
        to: 'noreply@sysmail.server.com', // list of receivers
        subject: 'Sysmon Test email ✔', // Subject line
        text: 'Test email' // plaintext body
    };

    var result = {
        host: name,
        test_score: 0,
        message: ""
    }

    // send mail with defined transport object
    transporter.sendMail(mailOptions, function(error, info){
        if(error){
            result.message = error.response;
        } else {
            result.test_score = 100;
            result.message = info.response;
        }
        db.save("smtp", result);
    });
    
}

module.exports = {
    configure: configure,
    test: test
}
