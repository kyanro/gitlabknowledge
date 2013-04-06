## 今回もとりあえず動いたレベルです(´・ω・｀)
	http://www.cocoalife.net/2010/10/post_77.html
	および
	http://n.blueblack.net/articles/2012-07-29_01_nginx_unicorn_redmine_02/
	を参考にしました。

	


## 1:redmineユーザに切り替え後、redmineユーザのredmineのディレクトリに移動
	su redmine
	cd /home/redmine/redmine/


## 2:unicornのインストール
	sudo gem install unicorn


## 3:unicorn.rbの作成
	vim config/unicorn.rb

	#unicorn.rbを下記のファイルと同じように設定する
[unicorn.rb](https://github.com/kyanro/gitlabknowledge/blob/5.x/nginx/redmine)


## 4:unicornの起動
	unicorn_rails -c config/unicorn.rb -E production -D


## 5:nginxの設定
	#/etc/nginx/sites-available/redmine を下記のファイルと同じように設定する
	sudo vim /etc/nginx/sites-available/redmine
	sudo ln -s /etc/nginx/sites-available/redmine /etc/nginx/sites-enabled/redmine
[/etc/nginx/sites-available/redmine](https://github.com/kyanro/gitlabknowledge/blob/5.x/nginx/redmine)


## 6:nginxサーバの再起動
	sudo /etc/init.d/nginx stop
	sudo /etc/init.d/nginx start


## 7:redmineで利用するunicorn を自動起動に登録
	#起動スクリプトの作成
	#下記のファイルのように設定
	sudo vim /etc/init.d/unicorn_redmine
[/etc/init.d/unicorn_redmine](https://github.com/kyanro/gitlabknowledge/blob/5.x/unicorn/unicorn_redmine)

	#実行権限の追加
	sudo chmod +x /etc/init.d/unicorn_redmine

	#unicornの再起動
	sudo service unicorn_redmine stop
	sudo service unicorn_redmine start
	ps auxf