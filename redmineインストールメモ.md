## redmineユーザを作って/home/redmine にインストールしてみた
	#2013/04/07追記
	#gitグループに他のユーザを所属させるとなぜか公開鍵を利用したpushやpullができなくなった
	#gitlab-shell の問題？よくわからない。(1.1,1.2ともにエラーとなった)
	#/home/git/repositories/ にredmineから読み取り権限をつければいいかとも思ったけどうまくいかなかったし
	#みえないところでgitlabに副作用がでるのもあれだと思ったので、
	#redmineユーザを作らずに、既存のgitユーザ(gitlab用に作った奴)でredmineをインストールする方向に方針転換決定

	linux系OSにアプリをインストールするときのお作法はなんとなくわかってきた。
	が、とりあえず動くレベルです。
	gitlabの流れを真似しながらいれてみたつもり。

	残作業
		メールサーバの設定


## 1:redmineのくろーん
	cd /home/git
	sudo -u git -H git clone git://github.com/redmine/redmine.git

	#チェックアウト
	cd /home/git/redmine/
	sudo -u git -H git checkout 2.3.0
	sudo -u git -H git checkout -b 2.3.0


## 2:データベースの作成
	#mysqlにrootでログイン
	mysql -u root -p

	#データベースの作成、ユーザの作成、権限の付与
	create database redmine character set utf8;
	create user 'redmine'@'localhost' identified by 'sa1234';
	grant all privileges on redmine.* to 'redmine'@'localhost';

	#mysqlから抜ける
	quit


## 3:データベースとメールサーバの設定
	#configファイルのコピーと編集
	#production の username:redmine password:"sa1234" と仮定
	sudo -u git -H cp config/database.yml.example config/database.yml
	sudo -u git -H vim config/database.yml

	#メールサーバの設定は今は飛ばした


## 4:bundlerを利用してインストール --pathを利用
	sudo -u git -H bundle install --path vendor/bundle --without development test postgresql sqlite rmagick


## 5:セッションストア秘密鍵を生成
	sudo -u git -H bundle exec rake generate_secret_token


## 6:データベース上にテーブルを作成
	sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production


## 7:下記コマンドを実行し、デフォルトデータをデータベースに登録
	#言語を聞かれるので ja を入力
	sudo -u git -H bundle exec rake redmine:load_default_data RAILS_ENV=production


## 8:書き込み権限が必要なディレクトリの作成と設定
	#すでにディレクトリがあったら mkdir は飛ばしてok
	sudo -u git -H mkdir tmp public/plugin_assets

	sudo chown -R git:git files log tmp public/plugin_assets
	sudo chmod -R 755 files log tmp public/plugin_assets
	
	
## 9:WEBrickによるwebサーバを起動して、インストールができたかテスト
	sudo -u git -H ruby script/rails server webrick -e production

## 10:WEBrickが起動したら、ブラウザで http://localhost:3000/ を開く。Redmineのwelcomeページが表示されるはず。
	#注意書きが下記のようにあったので、gitlabで利用しているnginx上での動作に変更するために今度がんばる
	注意: Webrickは通常は開発時に使用すものであり、通常の運用には適していません。動作確認以外には使用しないでください。
	本番運用においてはPassenger (mod_rails) や mongrel の利用を検討してください。

## 11:デフォルトの管理者アカウントでログインできるか確認
	login: admin
	password: admin
	
	ログインできることを確認したらWEBrickをCTRL+Cでとめる


# 12:ここからブラウザでの操作
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


## 3回目入れてみての感想
ローカルならまぁ同じユーザで動いててもいいよね(´・ω・｀)？