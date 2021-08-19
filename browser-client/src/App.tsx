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
    } else if ((12449 <= correctCharCode && correctCharCode < 12534) || correctChar === 'ー') { // カタカナ (ァ-ヶ) か長音 (カタカナのことが多い)
        choices.push(...sampleSize(range(12449, 12535), 3));
    } else if (65313 <= correctCharCode && correctCharCode <= 65339) { // 全角英字 (Ａ-Ｚ)
        choices.push(...sampleSize(range(65313, 65339), 3));
    } else if (65296 <= correctCharCode && correctCharCode < 65306) {
        choices.push(...sampleSize(range(65296, 65306), 3));
    } else { // ひらがなとみなす
        choices.push(...sampleSize(range(12353, 12435), 3)); // ぁ-ん
    }
    return shuffle(choices.map(choice => String.fromCharCode(choice)));
};

const fetchNextProblem = async (roomId: string) => {
    const res = await fetch(`${HOST}/api/problems/next?roomId=${roomId}`);
    const data = await res.json();
    if (data.available) {
        const problem: Problem = {
            id: data.id,
            question: data.question,
            answer: data.answer,
            answerInKana: data.answerInKana,
        };
        return problem;
    }
    return null;
};

const App: React.FC = () => {
    const [userId, setUserId] = useState<string>('');
    const [userName, setUserName] = useState<string>('名無し');
    const [roomId, setRoomId] = useState<string | null>(null);
    const [memberNames, setMemberNames] = useState<string[]>([userName]);
    const [status, setStatus] = useState<'waiting' | 'attending' | 'answering' | 'result' | null>(null);
    const [currentProblem, setCurrentProblem] = useState<Problem | null>(null);
    const [myAnswer, setMyAnswer] = useState('');
    const [answerBlocked, setAnswerBlocked] = useState(false);
    const [score, setScore] = useState({ me: 0, opponent: 0 });
    const [socket, setSocket] = useState<Socket | null>(null);
    useEffect(() => {
        const id = uuid();
        setUserId(id);
        const s = io(HOST);
        setSocket(s);
    }, []);
    useEffect(() => {
        if (status === 'waiting') {
            socket?.emit('join-room', {
                userId, userName,
            });
            // socket?.on('room-created', param => {
            //     console.log(`[room-created] Room id: ${param.roomId}`);
            // });
            // socket?.on('room-updated', param => {
            //     console.log(`[room-updated] Current members: ${param.memberNames.join(', ')}`);
            // });
            socket?.on('room-ready', param => {
                setRoomId(param.roomId);
                setMemberNames(param.memberNames);
                setStatus('attending');
            });
        }
        if (status === 'attending') {
            if (currentProblem === null && roomId) {
                fetchNextProblem(roomId).then(problem => {
                    if (problem) {
                        setCurrentProblem(problem);
                    } else {
                        setStatus('result');
                    }
                });
            }
        }
        if (status === 'attending') {
            socket?.on('answer-blocked', param => {
                setAnswerBlocked(true);
            });
            socket?.on('problem-answered', param => {
                setAnswerBlocked(false);
                if (param.isCorrect) {
                    setScore({
                        me: score.me,
                        opponent: score.opponent + 1,
                    });
                }
            });
            socket?.on('problem-closed', param => {
                setAnswerBlocked(false);
                setCurrentProblem(null);
            });
        }
        socket?.on('room-closed', param => {
            setStatus(null);
            setRoomId(null);
        });
    }, [status, currentProblem]);
    if (currentProblem) {
        console.log('答え: ' + currentProblem?.answerInKana); // 不正用
    }
    return (
        <div style={{ textAlign: 'center' }}>
            <h1>interlinQ Browser Client</h1>
            <div>
                status: {status || 'null'}
            </div>
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
                    <button onClick={() => { setStatus('waiting'); }} >入室する</button>
                }
                {status === 'waiting' &&
                    <p>待機中…</p>
                }
                {status !== null &&
                    <button onClick={() => {
                        socket?.emit('close-room', { roomId });
                        setStatus('waiting');
                    }}>退出する</button>
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
                                    makeChoices(currentProblem.answerInKana[myAnswer.length]).map((choice, i) =>
                                        <button
                                            key={i}
                                            onClick={() => {
                                                const updatedAnswer = myAnswer + choice;
                                                if (currentProblem.answerInKana.startsWith(updatedAnswer)) {
                                                    if (currentProblem.answerInKana === updatedAnswer) { // 解答終了・正答
                                                        socket?.emit('submit-answer', {
                                                            userId,
                                                            roomId,
                                                            isCorrect: true,
                                                        });
                                                        setScore({
                                                            me: score.me + 1,
                                                            opponent: score.opponent
                                                        });
                                                        setStatus('attending');
                                                        setCurrentProblem(null);
                                                    } else { // 解答途中
                                                        setMyAnswer(myAnswer + choice);
                                                    }
                                                } else { // 誤答
                                                    socket?.emit('submit-answer', {
                                                        userId,
                                                        roomId,
                                                        isCorrect: false,
                                                    });
                                                    setStatus('attending');
                                                    setAnswerBlocked(true);
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
                {status === 'result' &&
                    <div>
                        <p>あなたの点数: {score.me}</p>
                        <p>相手の点数: {score.opponent}</p>
                    </div>
                }
            </div>
        </div>
    );
};

export default App;
