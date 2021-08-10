# interlinQ-server

interlinQ のサーバー実装です。TypeScript を使用しています。

## API

### `/problems/random`

問題をランダムで返します。`?n=3` などと問題数を指定できます (指定されていない場合、5問)。

戻り値:
```
{
    question: string;
    answer: string;
    answerInKana: string;
}[];
```

## 開発

1. このディレクトリに移動
1. 初回のみ `npm install`
1. `npm run develop` (ファイルが変更されるたびにサーバーが自動で再起動します)

また、test.html をローカルで開くことで、WebSocket の動作確認ができます。

## 動かし方

1. `npm run build` で生成される index.js を実行します。
