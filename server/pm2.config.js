const productionHost = 'tk2-221-20494.vs.sakura.ne.jp';

module.exports = {
    apps: [{
        script: 'index.js',
        name: 'interlinq-server-deployment'
    }],
    deploy: {
        production: {
            key: '~/.ssh/id_ed25519',
            ssh_options: 'StrictHostKeyChecking=no',
            user: 'yasumoto',
            host: productionHost,
            ref: 'origin/main',
            repo: 'git@github.com:ernix/interlinQ.git',
            path: '/home/yasumoto/test',
            'post-deploy': 'cd server && npm install && npm run build && pm2 start pm2.config.js',
        },
    },
};
