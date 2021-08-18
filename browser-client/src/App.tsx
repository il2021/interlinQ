/* eslint-disable @next/next/no-img-element */
import { useState } from 'react';

const App = () => {
    const [userName, setUserName] = useState<string>('名無し');
    const [status, setStatus] = useState<'waiting' | null>(null);
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
                {
                    status === null && <button onClick={() => setStatus('waiting')}>入室する</button>
                }
            </div>
        </div>
    );
};

export default App;
