import fastify from 'fastify';
import fastifyWebSocket from 'fastify-websocket';
import { sampleSize } from 'lodash';
import fs from 'fs';

const problems = fs.readFileSync('../content/quiz.tsv', 'utf-8').split('\n').map(line => {
    const [ question, answer, answerInKana ] = line.split('\t');
    return { question, answer, answerInKana };
});

const server = fastify();
server.register(fastifyWebSocket);

server.get<{
    Querystring: {
        n?: number;
    };
}>('/api/problems/random', async (request, reply) => {
    const n = request.query.n || 5;
    return sampleSize(problems, n);
});

server.get('/ws', { websocket: true }, (connection, req) => {
    connection.socket.send('Welcome!');
    connection.socket.on('message', message => {
        connection.socket.send(message);
    });
});

server.listen(8080);
