import fastify from 'fastify';
import fastifyCors from 'fastify-cors';
import { Server } from 'socket.io';
import { v4 as uuid } from 'uuid';
import { sample, sampleSize, countBy } from 'lodash';
import fs from 'fs';

interface Problem {
    id: string;
    question: string;
    answer: string;
    answerInKana: string;
}

const problems: Problem[] = fs.readFileSync('../content/quiz.tsv', 'utf-8').split('\n').map(line => {
    const [id, question, answer, answerInKana] = line.split('\t');
    return { id, question, answer, answerInKana };
});

const getOneRandomProblem = () => sample(problems) as Problem;

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
app.register(fastifyCors, {
    origin: '*',
});

app.get<{
    Querystring: {
        n?: number;
    };
}>('/api/problems/random', async request => {
    console.warn('This endpoint is deprecated.');
    const n = request.query.n || 5;
    return sampleSize(problems, n);
});

app.get<{
    Querystring: {
        roomId: string;
    };
}>('/api/problems/next', async request => {
    const roomId = request.query.roomId;
    const rooms = activeRooms.filter(room => room.roomId === roomId);
    if (rooms.length === 0) {
        return {
            available: false,
        };
    }
    const room = rooms[0];
    const latestProblemId = room.problemIds.slice(-1)[0];
    const latestProblem = problems.filter(problem => problem.id === latestProblemId)[0]; // 遅そ〜。index できる db に入れたいね
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
            room.members.push({
                id: userId,
                name: userName,
                answerPermitted: true,
            });
            socket.join(room.roomId);
            const res = {
                roomId: room.roomId,
                memberNames: room.members.map(member => member.name),
            };
            io.to(room.roomId).emit('room-updated', res);
            io.to(room.roomId).emit('room-ready', res);
            const firstProblem = getOneRandomProblem().id;
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
        socket.to(roomId).emit('answer-blocked', { answeringUserName: user.name });
    });
    socket.on('submit-answer', params => {
        const roomId = params.roomId as string;
        const userId = params.userId as string;
        const room = activeRooms.filter(room => room.roomId === roomId)[0];
        const user = room.members.filter(member => member.id === userId)[0];
        const isCorrect = params.isCorrect as boolean;
        socket.to(roomId).emit('problem-answered', {
            userName: user.name,
            isCorrect,
        });
        if (isCorrect) {
            io.to(roomId).emit('problem-closed');
            if (room.solverIds.filter(solverId => solverId !== null).length === 5) {
                const solvesDict = countBy(room.solverIds.filter(solverId => solverId !== null));
                const winnerId = Object.entries(solvesDict).sort((a, b) => a < b ? 1 : -1)[0][0];
                const winnerName = room.members.filter(member => member.id === winnerId)[0].name;
                io.to(roomId).emit('room-closed', {
                    succeeded: true,
                    winnerName: winnerName,
                });
                activeRooms.splice(activeRooms.findIndex(room => room.roomId === roomId), 1);
            } else {
                const nextProblem = getOneRandomProblem().id;
                room.problemIds.push(nextProblem);
                room.solverIds.push(userId);
                room.members.forEach(member => {
                    member.answerPermitted = true;
                });
            }
        } else {
            room.members.forEach(member => {
                if (member.id === userId) {
                    member.answerPermitted = false;
                }
            });
            if (room.members.every(member => member.answerPermitted === false)) {
                io.to(roomId).emit('problem-closed');
                const nextProblem = getOneRandomProblem().id;
                room.problemIds.push(nextProblem);
                room.solverIds.push(null);
                room.members.forEach(member => {
                    member.answerPermitted = true;
                });
            }
        }
    });
    socket.on('close-room', params => {
        const roomId = params.roomId as string;
        activeRooms.splice(activeRooms.findIndex(room => room.roomId === roomId), 1);
        io.to(roomId).emit('room-closed');
    });
});

app.listen(8080, '0.0.0.0');
