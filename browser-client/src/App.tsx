/* eslint-disable react-hooks/exhaustive-deps */
/* eslint-disable @next/next/no-img-element */
import { useState, useEffect } from 'react';
import { io, Socket } from 'socket.io-client';
import { v4 as uuid } from 'uuid';

const App = () => {
    const [log, setLog] = useState<string>('');
    const addLog = (s: string) => { setLog(log + '\n' + s); };
    const [userId, setUserId] = useState<string>('');
    const [userName, setUserName] = useState<string>('名無し');
    const [status, setStatus] = useState<'waiting' | null>(null);
    const [socket, setSocket] = useState<Socket | null>(null);
    socket?.on('connect', () => {
        addLog('Connected.');
    });
    useEffect(() => {
        const id = uuid();
        setUserId(id);
        addLog(`Your userId is ${id}`);
        const s = io('http://localhost:8080');
        setSocket(s);
    }, []);
    useEffect(() => {
        if (status === 'waiting') {
            socket?.emit('join-room', {
                userId, userName,
            });
            socket?.on('room-created', param => {
                addLog(`Room created: ${param.roomId}`);
            });
            socket?.on('room-updated', param => {
                addLog(`Room updated. Current members: ${param.memberNames.join(', ')}`);
            });
            socket?.on('room-ready', param => {
                addLog(`Room ready. Room ID: ${param.roomId} Current members: ${param.memberNames.join(', ')}`);
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
                {
                    status === null && <button onClick={() => { setStatus('waiting'); addLog('Set status as waiting.'); }}>入室する</button>
                }
                {
                    status === 'waiting' && <p>待機中…</p>
                }
            </div>
        </div>
    );
};

export default App;
