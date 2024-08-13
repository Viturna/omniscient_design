# config/puma.rb
workers 2
threads 1, 6

preload_app!

port 3000
environment ENV['RAILS_ENV'] || 'development'

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
