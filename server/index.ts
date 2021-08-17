import fastify from 'fastify';
import { Server } from 'socket.io';
import { v4 as uuid } from 'uuid';
import { sample, sampleSize } from 'lodash';
import fs from 'fs';

const problems = fs.readFileSync('../content/quiz.tsv', 'utf-8').split('\n').map(line => {
    const [ id, question, answer, answerInKana ] = line.split('\t');
    return { id, question, answer, answerInKana };
});

interface Member {
    id: string; // Don't pass to clients!
    name: string;
    score: number;
    answerPermitted: boolean;
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
                        score: 0,
                        answerPermitted: true,
                    },
                ],
            });
            socket.join(roomId);
            io.to(roomId).emit('room-created', { roomId });
        }
    });
    socket.on('start-answer', params => {
        const userId = params.userId as string;
        const roomId = params.roomId as string;
        const room = activeRooms.filter(room => room.roomId === roomId)[0];
        const user = room.members.filter(member => member.id === userId)[0];
        io.to(roomId).emit('answer-blocked', { answeringUserName: user.name });
    });
    socket.on('submit-answer', params => {
        const userId = params.userId as string;
        const roomId = params.roomId as string;
        const room = activeRooms.filter(room => room.roomId === roomId)[0];
        const isCorrect = params.isCorrect as boolean;
        io.to(roomId).emit('answer-unblocked');
        if (isCorrect) {
            const nextProblem = sample(problems)!.id;
            const updatedMembers = room.members.map(member => {
                if (member.id === userId) {
                    member.score += 1;
                }
                member.answerPermitted = true;
                return member;
            });
            activeRooms.push({
                roomId,
                members: updatedMembers,
                problemIds: [...room.problemIds, nextProblem],
            });
        } else {
            const updatedMembers = room.members.map(member => {
                if (member.id === userId) {
                    member.answerPermitted = false;
                }
                return member;
            });
            activeRooms[activeRooms.length - 1].members = updatedMembers;
            if (room.members.every(member => member.answerPermitted === false)) {
                const nextProblem = sample(problems)!.id;
                const updatedMembers = room.members.map(member => {
                    member.answerPermitted = true;
                    return member;
                });
                activeRooms.push({
                    roomId,
                    members: updatedMembers,
                    problemIds: [...room.problemIds, nextProblem],
                });
            }
        }
    });
});

app.listen(8080, '0.0.0.0');
