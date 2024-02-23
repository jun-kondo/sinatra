# アプリの使用方法
## リポジトリをクローン
```
git clone -b add-memo https://github.com/jun-kondo/sinatra.git
```
`cd sinatra`でアプリのディレクトリに移動
## アプリの起動に必要なgemをインストール
```
bundle install
```
## データベースを作成
postgresで`memo_app`データベースを作成
```
CREATE DATABASE memo_app WITH OWNER <USER NAME>;
```
## サーバーを起動
データベースが作成されていればサーバー起動時にテーブルが作成されます。
```
bundle exec ruby main.rb -p 4567
```
サーバーの起動後`http://localhost:4567/` にアクセス

