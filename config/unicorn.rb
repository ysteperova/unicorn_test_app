rails_root = "current"
pid_file   = "unicorn.pid"
socket_file= "/var/www/webroot/ROOT/tmp/sockets/unicorn.socket"
log_file   = "log/unicorn.log"
err_log    = "log/unicorn_error.log"
old_pid    = pid_file + '.oldbin'

environment ENV['RAILS_ENV'] || 'development'

timeout 30
worker_processes 4 
listen socket_file, :backlog => 1024
pid pid_file
stderr_path err_log
stdout_path log_file

preload_app true 

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=) 

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{rails_root}/Gemfile"
end

before_fork do |server, worker|

  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.connection.disconnect!

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCHu
    end
  end
end

after_fork do |server, worker|

  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.establish_connection
end

