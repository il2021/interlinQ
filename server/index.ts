import fastify from 'fastify';
import { Server } from 'socket.io';
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

const io = new Server(app.server, {
    cors: {
        origin: '*',
    },
});

io.on('connection', socket => {
    console.log('Connected');
    socket.on('disconnect', () => {
        console.log('Disconnected');
    });
    socket.on('from_client', obj => {
        console.log('Received data from client: ', obj);
    });

    socket.on('getQuestion', () => {
        socket.on('getQuestion', () => {
            console.log('リクエストを受け取った');
            sendQuestion();
        })
    });

});

const sendQuestion = () => {
    io.emit('responseQuestion', "問題：回答");
    console.log('問題送信');
};



const sendServerTime = () => {
    const now = new Date();
    io.emit('from_server', now.toLocaleString());
    console.log(now.toLocaleString());
    setTimeout(sendServerTime, 1000);
};
sendServerTime();

app.listen(8080);
