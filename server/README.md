# interlinQ-server

interlinQ のサーバー実装です。TypeScript を使用しています。

## 開発

1. このディレクトリに移動
1. 初回のみ `npm install`
1. `npm run develop` (ファイルが変更されるたびにサーバーが自動で再起動します)

また、test.html をローカルで開くことで、WebSocket の動作確認ができます。

## 動かし方

1. `npm run build` で生成される index.js を実行します。

## サーバーへのデプロイ方法

本番サーバーに SSH できる任意のマシンで `pm2 deploy server/pm2.config.js production` を実行します (要 pm2)。

server/ に変更がないが一応デプロイし直したい場合、`--force` が要ります。

GitHub Actions による自動デプロイを設定したいなと思っていますが、SSH 設定がうまく行っておらず、棚上げにしています…。現状では手動デプロイが必要です。

## 仕様

[Wiki](https://github.com/il2021/interlinQ/wiki/%E9%80%9A%E4%BF%A1%E4%BB%95%E6%A7%98-(API-%E3%81%A8-socket-event)) にまとめていますのでそちらをご参照ください。
