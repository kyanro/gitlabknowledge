## 今回もとりあえず動いたレベルです(´・ω・｀)
	http://www.cocoalife.net/2010/10/post_77.html
	を参考にしました


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
[redmine](https://github.com/kyanro/gitlabknowledge/blob/5.x/nginx/redmine)


## 6:nginxサーバの再起動
	sudo /etc/init.d/nginx stop
	sudo /etc/init.d/nginx start
