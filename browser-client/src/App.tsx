/* eslint-disable react-hooks/exhaustive-deps */
/* eslint-disable @next/next/no-img-element */
import { useState, useEffect } from 'react';
import { io, Socket } from 'socket.io-client';
import { v4 as uuid } from 'uuid';
import { range, sampleSize, shuffle } from 'lodash';

interface Problem {
    id: string;
    question: string;
    answer: string;
    answerInKana: string;
}

const HOST = 'http://localhost:8080';
// const HOST = 'http://tk2-221-20494.vs.sakura.ne.jp:8080';

const makeChoices = (correctChar: string) => {
    const correctCharCode = correctChar.charCodeAt(0);
    const choices = [correctCharCode];
    if (47 <= correctCharCode && correctCharCode < 58) { // 数字
        choices.push(...sampleSize(range(47, 58), 3));
    } else if (12449 <= correctCharCode && correctCharCode < 12534) { // カタカナ (ァ-ヶ)
        choices.push(...sampleSize(range(12449, 12535), 3));
    } else { // ひらがなとみなす
        choices.push(...sampleSize(range(12353, 12435), 3)); // ぁ-ん
    }
    return shuffle(choices.map(choice => String.fromCharCode(choice)));
};

const App: React.FC = () => {
    const [log, setLog] = useState<string>('');
    const addLog = (s: string) => { setLog(log + '\n' + s); };
    const [userId, setUserId] = useState<string>('');
    const [userName, setUserName] = useState<string>('名無し');
    const [roomId, setRoomId] = useState<string | null>(null);
    const [memberNames, setMemberNames] = useState<string[]>([userName]);
    const [status, setStatus] = useState<'waiting' | 'attending' | 'answering' | null>(null);
    const [currentProblem, setCurrentProblem] = useState<Problem | null>(null);
    const [myAnswer, setMyAnswer] = useState('');
    const [answerBlocked, setAnswerBlocked] = useState(false);
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
                setAnswerBlocked(true);
            });
            socket?.on('problem-answered', param => {
                addLog(`[problem-answered] User name: ${param.userName} isCorrect: ${param.isCorrect}`);
                setAnswerBlocked(false);
            });
            socket?.on('room-closed', param => {
                addLog(`[room-closed] Succeeded: ${param.succeeded} Winner name: ${param.winnerName}`);
                setStatus(null);
                setRoomId(null);
            });
        }
    }, [status]);
    if (currentProblem) {
        console.log('答え: ' + currentProblem?.answerInKana); // 不正用
    }
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
                {(status === 'attending' || status === 'answering') &&
                    <div>
                        <p>参加者: {memberNames.join(', ')}</p>
                        {currentProblem && (
                            <div>
                                <h2>問題</h2>
                                <p>{currentProblem?.question}</p>
                                {status === 'attending' &&
                                    <button
                                        disabled={answerBlocked}
                                        onClick={() => {
                                            setStatus('answering');
                                            setMyAnswer('');
                                            socket?.emit('start-answer', { userId, roomId });
                                            addLog('Emitted start-answer.');
                                        }}
                                    >
                                        解答
                                    </button>
                                }
                                {status === 'answering' &&
                                    <p style={{
                                        fontSize: 16,
                                    }}>
                                        {myAnswer}
                                    </p>
                                }
                                {status === 'answering' &&
                                    makeChoices(currentProblem.answerInKana[myAnswer.length]).map(choice =>
                                        <button
                                            key={choice}
                                            onClick={() => {
                                                const updatedAnswer = myAnswer + choice;
                                                if (currentProblem.answerInKana.startsWith(updatedAnswer)) {
                                                    if (currentProblem.answerInKana === updatedAnswer) { // 解答終了・正答
                                                        setMyAnswer('');
                                                        socket?.emit('submit-answer', {
                                                            userId,
                                                            roomId,
                                                            isCorrect: true,
                                                        });
                                                        setStatus('attending');
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
                                                    } else { // 解答途中
                                                        setMyAnswer(myAnswer + choice);
                                                    }
                                                } else { // 誤答
                                                    setMyAnswer('');
                                                    socket?.emit('submit-answer', {
                                                        userId,
                                                        roomId,
                                                        isCorrect: false,
                                                    });
                                                    setStatus('attending');
                                                }
                                            }}
                                            style={{
                                                width: 40,
                                                height: 40,
                                                margin: 10,
                                                fontSize: 16,
                                            }}
                                        >
                                            {choice}
                                        </button>
                                    ).flat()
                                }
                            </div>
                        )}
                    </div>
                }
            </div>
        </div>
    );
};

export default App;
