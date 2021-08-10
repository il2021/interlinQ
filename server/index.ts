import WebSocket from 'ws';

const wss = new WebSocket.Server({ host: '0.0.0.0', port: 8081 });

wss.on('connection', ws => {
    ws.send('Welcome!');
    ws.on('message', payload => {
        wss.clients.forEach(client => {
            client.send(payload.toString());
        });
    });
});
