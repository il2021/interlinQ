/* eslint-disable react-hooks/exhaustive-deps */
/* eslint-disable @next/next/no-img-element */
import { useState, useEffect } from 'react';
import { io, Socket } from 'socket.io-client';
import { v4 as uuid } from 'uuid';

interface Problem {
    id: string;
    question: string;
    answer: string;
    answerInKana: string;
}

const HOST = 'http://localhost:8080';
// const HOST = 'http://tk2-221-20494.vs.sakura.ne.jp:8080';

const App = () => {
    const [log, setLog] = useState<string>('');
    const addLog = (s: string) => { setLog(log + '\n' + s); };
    const [userId, setUserId] = useState<string>('');
    const [userName, setUserName] = useState<string>('名無し');
    const [roomId, setRoomId] = useState<string | null>(null);
    const [memberNames, setMemberNames] = useState<string[]>([userName]);
    const [status, setStatus] = useState<'waiting' | 'attending' | null>(null);
    const [currentProblem, setCurrentProblem] = useState<Problem | null>(null);
    const [socket, setSocket] = useState<Socket | null>(null);
    socket?.on('connect', () => {
        addLog('Connected.');
    });
    useEffect(() => {
        const id = uuid();
        setUserId(id);
        addLog(`Your userId is ${id}`);
        const s = io(HOST);
        setSocket(s);
    }, []);
    useEffect(() => {
        if (status === 'waiting') {
            socket?.emit('join-room', {
                userId, userName,
            });
            socket?.on('room-created', param => {
                addLog(`[room-created] Room id: ${param.roomId}`);
            });
            socket?.on('room-updated', param => {
                addLog(`[room-updated] Current members: ${param.memberNames.join(', ')}`);
            });
            socket?.on('room-ready', param => {
                addLog(`[room-ready] Room id: ${param.roomId} Current members: ${param.memberNames.join(', ')}`);
                setRoomId(param.roomId);
                setMemberNames(param.memberNames);
                setStatus('attending');
                addLog('Set status as attending.');
            });
        }
        if (status === 'attending') {
            if (currentProblem === null) {
                fetch(`${HOST}/api/problems/next?roomId=${roomId}`).then(res => res.json()).then(data => {
                    if (data.available) {
                        const problem: Problem = {
                            id: data.id,
                            question: data.question,
                            answer: data.answer,
                            answerInKana: data.answerInKana,
                        };
                        addLog('Problem fecthed successfully.');
                        setCurrentProblem(problem);
                    } else {
                        addLog('Next problem unavailable.');
                    }
                }).catch(e => {
                    addLog(e);
                });
            }
            socket?.on('answer-blocked', param => {
                addLog(`[answer-blocked] Answering member: ${param.answeringUserName}`);
            });
            socket?.on('problem-answered', param => {
                addLog(`[problem-answered] User name: ${param.userName} isCorrect: ${param.isCorrect}`);
            });
            socket?.on('room-closed', param => {
                addLog(`[room-closed] Succeeded: ${param.succeeded} Winner name: ${param.winnerName}`);
                setStatus(null);
                setRoomId(null);
            });
        }
    }, [status]);
    return (
        <div style={{ textAlign: 'center' }}>
            <h1>interlinQ Browser Client</h1>
            <div>
                status: {status || 'null'}
            </div>
            <pre>{log}</pre>
            <div style={{ margin: '1em 0' }}>
                <label htmlFor='userName'>ユーザー名: </label>
                <input
                    id='userName'
                    value={userName}
                    disabled={status !== null}
                    onChange={e => setUserName(e.target.value)} />
            </div>
            <div>
                {status === null &&
                    <button onClick={() => {
                        setStatus('waiting');
                        addLog('Set status as waiting.');
                    }}>入室する</button>
                }
                {status === 'waiting' &&
                    <p>待機中…</p>
                }
                {status === 'attending' &&
                    <div>
                        <p>参加者: {memberNames.join(', ')}</p>
                        {currentProblem && (
                            <div>
                                <h2>問題</h2>
                                <p>{currentProblem?.question}</p>
                            </div>
                        )}
                    </div>
                }
            </div>
        </div>
    );
};

export default App;
