import fastify from 'fastify';
import { Server } from 'socket.io';
import { v4 as uuid } from 'uuid';
import { sampleSize } from 'lodash';
import fs from 'fs';

const problems = fs.readFileSync('../content/quiz.tsv', 'utf-8').split('\n').map(line => {
    const [ question, answer, answerInKana ] = line.split('\t');
    return { question, answer, answerInKana };
});

const app = fastify();

app.get<{
    Querystring: {
        n?: number;
    };
}>('/api/problems/random', async (request, reply) => {
    const n = request.query.n || 5;
    return sampleSize(problems, n);
});

app.get<{
    Querystring: {
        roomId: string;
    };
}>('/api/problems/next', async (request, reply) => {
    const roomId = request.query.roomId;
    // TODO: 既出は出さない
    return sampleSize(problems, 1);
});

const io = new Server(app.server, {
    cors: {
        origin: '*', // for local test
    },
});

const waitRooms: string[] = [];

io.on('connection', socket => {
    socket.on('join-room', params => {
        const { userId } = params;
        // TODO: 同一ユーザーはカウントしない
        if (waitRooms.length > 0) {
            const roomId = waitRooms[0];
            waitRooms.shift();
            socket.join(roomId);
            io.to(roomId).emit('room-ready', { roomId });
        } else {
            const roomId = uuid();
            waitRooms.push(roomId);
            socket.join(roomId);
            io.to(roomId).emit('room-created', { roomId });
        }
    });
});

app.listen(8080, '0.0.0.0');
