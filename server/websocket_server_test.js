var http = require("http");
var server = http.createServer(function(req,res) {
    res.write("Hello World!!");
    res.end();
});

// socket.ioの準備
var io = require('socket.io')(server);

// クライアント接続時の処理
io.on('connection', function(socket) {
    console.log("接続")

    // クライアント切断時の処理
    socket.on('disconnect', function() {
        console.log("接続中断")
    });
    // クライアントからの受信を受ける (socket.on)
    socket.on("from_client", function(obj){
        console.log("クライアントからの受信",obj)
    });
});

// とりあえず一定間隔でサーバ時刻を"全"クライアントに送る (io.emit)
var send_servertime = function() {
    var now = new Date();
    io.emit("from_server", now.toLocaleString());
    console.log(now.toLocaleString());
    setTimeout(send_servertime, 1000)
};
send_servertime();

server.listen(8080);

