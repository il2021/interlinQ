# Xcodegenのインストール
チームで開発しているとコンフリクトが起きやすいので.xcodeprojはXcodegenを使って自動生成させています。

Homebrewの場合
```
brew install xcodegen
```
その他のインストール方法は https://github.com/yonaskolb/XcodeGen を参照してください。

# .xcodeprojの生成

以下のコマンドで.xcodeprojを生成してください。
```
cd client
xcodegen generate
```

以下のログが出ると成功です。
```
⚙️  Generating plists...
⚙️  Generating project...
⚙️  Writing project...
Created project at /Users/username/interlinQ/client/client.xcodeproj
```
