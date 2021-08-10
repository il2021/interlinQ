import fastify from 'fastify';
import { sample } from 'lodash';
import fs from 'fs';

const problems = fs.readFileSync('../content/quiz.tsv', 'utf-8').split('\n').map(line => {
    const [ question, answer, answerInKana ] = line.split('\t');
    return { question, answer, answerInKana };
});

const server = fastify();

server.get('/problems/random', async () => {
    return sample(problems);
});

server.listen(8000);

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
