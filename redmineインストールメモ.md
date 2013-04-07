## redmineユーザを作って/home/redmine にインストールしてみた
	linux系OSにアプリをインストールするときのお作法はなんとなくわかってきた。
	が、とりあえず動くレベルです。
	gitlabの流れを真似しながらいれてみたつもり。

	残作業
		メールサーバの設定

## 1:System Users
	#redmineのために redmine ユーザを追加
	sudo adduser --disabled-login --gecos 'redmine' redmine


## 2:redmineのくろーん
	cd /home/redmine
	sudo -u redmine -H git clone git://github.com/redmine/redmine.git

	#チェックアウト
	cd /home/redmine/redmine/
	sudo -u redmine -H git checkout -b 2.3.0


## 3:データベースの作成
	#mysqlにrootでログイン
	mysql -u root -p

	#データベースの作成、ユーザの作成、権限の付与
	create database redmine character set utf8;
	create user 'redmine'@'localhost' identified by 'sa1234';
	grant all privileges on redmine.* to 'redmine'@'localhost';

	#mysqlから抜ける
	quit


## 4:データベースとメールサーバの設定
	#configファイルのコピーと編集
	#production の username:redmine password:"sa1234" と仮定
	sudo -u redmine -H cp config/database.yml.example config/database.yml
	sudo -u redmine -H vim config/database.yml

	#メールサーバの設定は今は飛ばした


## 5:bundlerを利用してインストール
	sudo -u redmine -H bundle exec install --path vendor/bundle --without development test postgresql sqlite rmagick


## 6:セッションストア秘密鍵を生成
	sudo -u redmine -H bundle exec rake generate_secret_token


## 7:データベース上にテーブルを作成
	sudo -u redmine -H bundle exec rake db:migrate RAILS_ENV=production


## 8:下記コマンドを実行し、デフォルトデータをデータベースに登録
	#言語を聞かれるので ja を入力
	sudo -u redmine -H bundle exec rake redmine:load_default_data RAILS_ENV=production


## 9:書き込み権限が必要なディレクトリの作成と設定
	#すでにディレクトリがあったら mkdir は飛ばしてok
	sudo -u redmine -H mkdir tmp public/plugin_assets

	sudo chown -R redmine:redmine files log tmp public/plugin_assets
	sudo chmod -R 755 files log tmp public/plugin_assets
	
	
## 10:WEBrickによるwebサーバを起動して、インストールができたかテスト
	sudo -u redmine -H ruby script/rails server webrick -e production

## 11:WEBrickが起動したら、ブラウザで http://localhost:3000/ を開く。Redmineのwelcomeページが表示されるはず。
	#注意書きが下記のようにあったので、gitlabで利用しているnginx上での動作に変更するために今度がんばる
	注意: Webrickは通常は開発時に使用すものであり、通常の運用には適していません。動作確認以外には使用しないでください。
	本番運用においてはPassenger (mod_rails) や mongrel の利用を検討してください。

## 12:デフォルトの管理者アカウントでログインできるか確認
	login: admin
	password: admin
	
	ログインできることを確認したらWEBrickをCTRL+Cでとめる


## 13:redmine上からgitlabのリポジトリを見れるようにする
	#gitlabをgitグループに追加
	sudo gpasswd -a redmine git
	
	#グループが反映されているか確認
	sudo -u redmine -H id

	#大体こんなかんじになってるはず。1001(git)があればOK
	#id=1002(redmine) gid=1002(redmine) groups=1002(redmine),1001(git)

	#WEBrickを立ち上げる
	sudo -u redmine -H ruby script/rails server webrick -e production


# 14:ここからブラウザでの操作
	redmineに管理者でログインし、`プロジェクト`>`新しいプロジェクト`から適当にプロジェクトを作成
	*モジュールのリポジトリにチェックが入っていることを確認
	
	`設定`>`リポジトリ`タブ>`新しいリポジトリ` をクリック
	
	`リポジトリのパス`にgitlabのリポジトリを指定。(下記のリポジトリ名は自分の環境に合わせて）
	`/home/git/repositories/hoge.git`

	`プロジェクト`>`作成したプロジェクト名`>`リポジトリ`タブ
	で、リポジトリの中身が見れることを確認
	
## おまけ
	リポジトリがutf8以外の文字コードを利用している場合
	`管理`>`設定`>`全般`>`添付ファイルとリポジトリのエンコーディング`
	に
	sjis,utf-8
	のようにカンマ区切りでエンコードを指定してやる。
	左側から順番にエンコーディングをためして、最初にエラーが発生せずに変換できた結果が採用される。


## 2回目入れてみての感想
ローカルならwebrickでの運用でよくね(´・ω・｀)？