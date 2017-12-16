

var clients = [];

var configure = function(server) {
    var io = require('socket.io').listen(server); // this tells socket.io to use our express server
    io.sockets.on('connection', function(socket) {
        clients.push(socket);
        console.log('A new client connected!');
    });

    io.sockets.on('ping', function(data) {
        console.log("Got command: " + data);
    });

    io.sockets.on('http', function(data) {
        console.log("Got request: " + data);
    });

    io.sockets.on('smtp', function(data) {
        console.log("Got request: " + data);
    });

    io.sockets.on('smtp', function(data) {
        console.log("Got request: " + data);
    });

}

module.exports = {
    configure: configure
}
