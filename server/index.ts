import fastify from 'fastify';
import fastifyWebSocket from 'fastify-websocket';
import { sample } from 'lodash';
import fs from 'fs';

const problems = fs.readFileSync('../content/quiz.tsv', 'utf-8').split('\n').map(line => {
    const [ question, answer, answerInKana ] = line.split('\t');
    return { question, answer, answerInKana };
});

const server = fastify();
server.register(fastifyWebSocket);

server.get('/problems/random', async () => {
    return sample(problems);
});

server.get('/', { websocket: true }, (connection, req) => {
    connection.socket.send('Welcome!');
    connection.socket.on('message', message => {
        connection.socket.send(message);
    });
});

server.listen(8080);
