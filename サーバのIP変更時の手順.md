## gitlab、gitlab shell、redmineおよびnginxの設定変更
	#redmineのIP変更は未確認
	
	#サーバのIPが192.168.1.222に変更になったと仮定

	#gitユーザに切り替え
	sudo su git
	
	#gitlab shellの設定変更と反映
	#URLの部分を変更したいURLに修正 (http://192.168.1.222:10080 に変更したと仮定)
	cd /home/git/gitlab-shell
	vim config.yml
	
	#gitlabの設定変更
	cd /home/git/gitlab
	vim config/gitlab.yml

	#gitユーザから抜けておく
	exit

	#nginxの設定変更
	sudo vim /etc/nginx/sites-available/gitlab
	#sudo vim /etc/nginx/sites-available/redmine

## gitlab、redmineおよびnginxの再起動
	#gitlab再起動
	sudo service gitlab stop
	sudo service gitlab start

	#redmine再起動
	#sudo service unicorn_redmine stop
	#sudo service unicorn_redmine start


	#サーバのIP変更後
	#nginx再起動
	sudo service nginx stop
	sudo service nginx start

