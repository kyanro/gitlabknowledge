app_dir = File.expand_path '../../', __FILE__
working_directory app_dir

# ワーカーの数
worker_processes 2

# タイムアウト
timeout 30

# ソケット
listen "#{app_dir}/tmp/sockets/unicorn.socket"

# プロセスid
pid "#{app_dir}/tmp/pids/unicorn.pid"

#エラーログ
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

# ダウンタイムなくす
preload_app true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end

user 'git', 'git'