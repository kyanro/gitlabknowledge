## 今回もとりあえず動いたレベルです(´・ω・｀)
	http://www.cocoalife.net/2010/10/post_77.html
	および
	http://n.blueblack.net/articles/2012-07-29_01_nginx_unicorn_redmine_02/
	を参考にしました。

	192.168.1.201:11080 でredmineを運用すると仮定 



## 1:gitユーザのredmineのディレクトリに移動
	cd /home/git/redmine/

	# pidsディレクトリを作成し、 gitユーザが書き込みできるようにする
	#全開までの手順でできているはずだが念のため
	sudo -u git -H mkdir tmp/pids/
	sudo chmod -R u+rwX  tmp/pids/


## 2:unicornをgemファイルに追加してインストール
	#gemをしている箇所に `gem 'unicorn'` を追加。
	sudo -u git vim Gemfile

	#インストール
	sudo -u git -H bundle install --path vendor/bundle --without development test postgresql sqlite rmagick


## 3:unicorn.rbの作成
	#unicorn.rbを下記のファイルと同じように設定する
	sudo -u git vim config/unicorn.rb

[unicorn.rb](https://github.com/kyanro/gitlabknowledge/blob/5.x/redmine/unicorn.rb)


## 4:unicornの起動確認
	#エラーが発生ないことを確認
	sudo -u git -H bundle exec unicorn_rails -c config/unicorn.rb -E production -D

	# プロセスを殺しておきたければ下記を実行しておく
	# sudo -u git kill -QUIT $(cat tmp/pids/unicorn.pid)

## 5:nginxの設定
	#/etc/nginx/sites-available/redmine を下記のファイルと同じように設定する
	#listen  192.168.1.201:11080; の部分は自分の環境に合わせる
	sudo vim /etc/nginx/sites-available/redmine
	sudo ln -s /etc/nginx/sites-available/redmine /etc/nginx/sites-enabled/redmine
[/etc/nginx/sites-available/redmine](https://github.com/kyanro/gitlabknowledge/blob/5.x/nginx/redmine)


## 6:nginxサーバの再起動
	sudo /etc/init.d/nginx stop
	sudo /etc/init.d/nginx start

	# unicornのプロセスを殺してなければここでいったんredmineがブラウザから表示できるか確認しておく
	# http://192.168.1.201:11080
	# 確認できたらプロセスを殺しておく
	# sudo -u git kill -QUIT $(cat tmp/pids/unicorn.pid)

## 7:redmineで利用するunicorn を自動起動に登録
	#起動スクリプトの作成
	#下記のファイルのように設定
	sudo vim /etc/init.d/unicorn_redmine
[/etc/init.d/unicorn_redmine](https://github.com/kyanro/gitlabknowledge/blob/5.x/unicorn/unicorn_redmine)

	#実行権限の追加
	sudo chmod +x /etc/init.d/unicorn_redmine

	#unicorn_redmineの登録
	sudo update-rc.d unicorn_redmine defaults

	#unicornがサービス化されているかテスト
	sudo service unicorn_redmine start
	
	# http://192.168.1.201:11080 でアクセスできるか確認

	# 停止の確認
	sudo service unicorn_redmine stop
