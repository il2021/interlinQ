import fastify from 'fastify';
import { Server } from 'socket.io';
import { v4 as uuid } from 'uuid';
import { sample, sampleSize, countBy } from 'lodash';
import fs from 'fs';

const problems = fs.readFileSync('../content/quiz.tsv', 'utf-8').split('\n').map(line => {
    const [ id, question, answer, answerInKana ] = line.split('\t');
    return { id, question, answer, answerInKana };
});

interface Member {
    id: string; // Don't pass to clients!
    name: string;
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
    solverIds: (string | null)[];
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
    const rooms = activeRooms.filter(room => room.roomId === roomId);
    if (rooms.length === 0) {
        return {
            available: false,
        };
    }
    const room = rooms[0];
    const latestProblemId = room.problemIds.slice(-1)[0];
    const latestProblem = problems.filter(problem => problem.id === latestProblemId); // 遅そ〜。index できる db に入れたいね
    return {
        available: true,
        ...latestProblem
    };
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
            console.log(res.roomId);
            io.to(room.roomId).emit('room-updated', res);
            io.to(room.roomId).emit('room-ready', res);
            const firstProblem = sample(problems)!.id;
            activeRooms.push({
                ...room,
                problemIds: [firstProblem],
                solverIds: [],
            });
        } else {
            const roomId = uuid();
            waitRooms.push({
                roomId,
                members: [
                    {
                        id: userId,
                        name: userName,
                        answerPermitted: true,
                    },
                ],
            });
            socket.join(roomId);
            io.to(roomId).emit('room-created', { roomId });
        }
    });
    socket.on('start-answer', params => {
        const roomId = params.roomId as string;
        const userId = params.userId as string;
        const room = activeRooms.filter(room => room.roomId === roomId)[0];
        const user = room.members.filter(member => member.id === userId)[0];
        io.to(roomId).emit('answer-blocked', { answeringUserName: user.name });
    });
    socket.on('submit-answer', params => {
        const roomId = params.roomId as string;
        const userId = params.userId as string;
        const room = activeRooms.filter(room => room.roomId === roomId)[0];
        const user = room.members.filter(member => member.id === userId)[0];
        const isCorrect = params.isCorrect as boolean;
        io.to(roomId).emit('problem-answered', {
            userName: user.name,
            isCorrect,
        });
        // io.to(roomId).emit('answer-unblocked'); // DEPRECATED
        if (isCorrect) {
            if (room.solverIds.filter(solverId => solverId !== null).length === 5) {
                const solvesDict = countBy(room.solverIds.filter(solverId => solverId !== null));
                const winnerId = Object.entries(solvesDict).sort((a, b) => a < b ? 1 : -1)[0][0];
                const winnerName = room.members.filter(member => member.id === winnerId)[0].name;
                io.to(roomId).emit('room-closed', {
                    succeeded: true,
                    winnerName: winnerName,
                });
                activeRooms.splice(activeRooms.findIndex(room => room.roomId), 1);
            } else {
                const nextProblem = sample(problems)!.id;
                room.solverIds.push(userId);
                room.members.forEach(member => {
                    member.answerPermitted = true;
                });
                activeRooms.push({
                    ...room,
                    problemIds: [...room.problemIds, nextProblem],
                });
            }
        } else {
            room.members.forEach(member => {
                if (member.id === userId) {
                    member.answerPermitted = false;
                }
            });
            if (room.members.every(member => member.answerPermitted === false)) {
                const nextProblem = sample(problems)!.id;
                room.members.forEach(member => {
                    member.answerPermitted = true;
                });
                activeRooms.push({
                    ...room,
                    problemIds: [...room.problemIds, nextProblem],
                });
            }
        }
    });
});

app.listen(8080, '0.0.0.0');
