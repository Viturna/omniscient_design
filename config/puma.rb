# config/puma.rb

workers 2
threads 1, 6

# Define directories
app_dir = File.expand_path('../..', __FILE__)
shared_dir = "#{app_dir}/shared"
current_dir = "#{app_dir}/current"

# Define environment
rails_env = ENV['RAILS_ENV'] || 'production'
environment rails_env

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
directory current_dir
rackup "#{current_dir}/config.ru"
pidfile "#{shared_dir}/tmp/pids/puma.pid"
state_path "#{shared_dir}/tmp/pids/puma.state"
bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

activate_control_app

on_worker_boot do
  require 'active_record'
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
