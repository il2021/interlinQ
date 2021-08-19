import fastify from 'fastify';
import fastifyCors from 'fastify-cors';
import { Server } from 'socket.io';
import { v4 as uuid } from 'uuid';
import { sample, countBy } from 'lodash';
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

const getMostAppearing = (a: unknown[]) => Object.entries(countBy(a)).sort((a, b) => a[1] < b[1] ? 1 : -1)[0];

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
        roomId: string;
    };
}>('/api/problems/next', async request => {
    const roomId = request.query.roomId;
    const room = roomIdToRoom(activeRooms, roomId);
    if (typeof room === 'undefined') {
        return {
            available: false,
        };
    }
    const latestProblemId = room.problemIds.slice(-1)[0];
    const latestProblem = problems.filter(problem => problem.id === latestProblemId)[0]; // 遅そ〜。index できる db に入れたいね
    return {
        available: true,
        ...latestProblem
    };
});

type PotentiallyUndefined<T> = T | undefined;

const roomIdToRoom = (activeRooms: ActiveRoom[], roomId: string) =>
    activeRooms.filter(room => room.roomId === roomId)[0] as PotentiallyUndefined<ActiveRoom>;

const memberIdToMember = (room: ActiveRoom, userId: string) =>
    room.members.filter(member => member.id === userId)[0] as PotentiallyUndefined<Member>;

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
        const room = roomIdToRoom(activeRooms, roomId);
        if (typeof room === 'undefined') {
            io.to(roomId).emit('room-closed', { succeeded: false });
            return;
        }
        const user = memberIdToMember(room, userId);
        if (typeof user === 'undefined') {
            io.to(roomId).emit('room-closed', { succeeded: false });
            return;
        }
        socket.to(roomId).emit('answer-blocked', { answeringUserName: user.name });
    });
    socket.on('submit-answer', params => {
        const roomId = params.roomId as string;
        const userId = params.userId as string;
        const room = roomIdToRoom(activeRooms, roomId);
        if (typeof room === 'undefined') {
            io.to(roomId).emit('room-closed', { succeeded: false });
            return;
        }
        const user = memberIdToMember(room, userId);
        if (typeof user === 'undefined') {
            io.to(roomId).emit('room-closed', { succeeded: false });
            return;
        }
        const isCorrect = params.isCorrect as boolean;
        socket.to(roomId).emit('problem-answered', {
            userName: user.name,
            isCorrect,
        });
        if (isCorrect) {
            room.solverIds.push(userId);
            room.members.forEach(member => {
                member.answerPermitted = true;
            });
            io.to(roomId).emit('problem-closed');
            const [topRunnerId, topRunnerScore] = getMostAppearing(room.solverIds);
            if (topRunnerScore >= 5) { // Since it's incremental, this will be exactly 5
                const winnerId = topRunnerId;
                const winner = memberIdToMember(room, winnerId);
                if (typeof winner === 'undefined') {
                    io.to(roomId).emit('room-closed', { succeeded: false });
                    return;
                }
                const winnerName = winner.name;
                room.problemIds = [];
                activeRooms.splice(activeRooms.findIndex(room => room.roomId === roomId), 1);
                io.to(roomId).emit('room-closed', {
                    succeeded: true,
                    winnerName: winnerName,
                });
            } else {
                const nextProblem = getOneRandomProblem().id;
                room.problemIds.push(nextProblem);
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
        io.to(roomId).emit('room-closed', { succeeded: false });
    });
});

app.listen(8080, '0.0.0.0');
