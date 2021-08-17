import fastify from 'fastify';
import { Server } from 'socket.io';
import { v4 as uuid } from 'uuid';
import { sample, sampleSize } from 'lodash';
import fs from 'fs';

const problems = fs.readFileSync('../content/quiz.tsv', 'utf-8').split('\n').map(line => {
    const [ question, answer, answerInKana ] = line.split('\t');
    const id = 'TODO:';
    return { id, question, answer, answerInKana };
});

interface Member {
    id: string; // Don't pass to clients!
    name: string;
}

interface WaitRoom {
    roomId: string;
    members: Member[];
}

interface ActiveRoom {
    roomId: string;
    members: Member[];
    problemIds: string[];
}

const waitRooms: WaitRoom[] = [];
const activeRooms: ActiveRoom[] = [];

const app = fastify();

app.get<{
    Querystring: {
        n?: number;
    };
}>('/api/problems/random', async (request, reply) => {
    console.warn('This endpoint is deprecated.');
    const n = request.query.n || 5;
    return sampleSize(problems, n);
});

app.get<{
    Querystring: {
        roomId: string;
    };
}>('/api/problems/next', async (request, reply) => {
    const roomId = request.query.roomId;
    const room = activeRooms.filter(room => room.roomId === roomId)[0];
    const latestProblemId = room.problemIds.slice(-1)[0];
    const latestProblem = problems.filter(problem => problem.id === latestProblemId); // 遅そ〜。index できる db に入れたいね
    return latestProblem;
});

const io = new Server(app.server, {
    cors: {
        origin: '*', // for local test
    },
});

io.on('connection', socket => {
    socket.on('join-room', params => {
        const userId = params.userId as string;
        const userName = params.userName as string;
        if (waitRooms.length > 0) {
            // とりあえず2人部屋のみとするので、直ちに ready 化
            const room = waitRooms.shift() as WaitRoom;
            socket.join(room.roomId);
            const res = {
                roomId: room.roomId,
                memberNames: room.members.map(member => member.name),
            };
            io.to(room.roomId).emit('room-updated', res);
            io.to(room.roomId).emit('room-ready', res);
            const firstProblem = sample(problems)!.id;
            activeRooms.push({ ...room, problemIds: [ firstProblem ] });
        } else {
            const roomId = uuid();
            waitRooms.push({
                roomId,
                members: [
                    {
                        id: userId,
                        name: userName,
                    },
                ],
            });
            socket.join(roomId);
            io.to(roomId).emit('room-created', { roomId });
        }
    });
});

app.listen(8080, '0.0.0.0');
