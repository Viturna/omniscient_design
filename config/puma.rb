# Threads configuration
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Workers configuration
if ENV["RAILS_ENV"] == "production"
  require "concurrent-ruby"
  worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count })
  workers worker_count if worker_count > 1
end

# Timeout for workers in development
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Port binding
port ENV.fetch("PORT") { 3000 }

# Environment setting
environment ENV.fetch("RAILS_ENV") { "production" }

# PID file
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# State file (optional, for monitoring)
state_path ENV.fetch("STATE_PATH") { "tmp/pids/puma.state" }

# Daemonize (optional, if you want Puma to run as a background process)
# daemonize ENV.fetch("DAEMONIZE") { true }

# Allow puma to be restarted by `bin/rails restart`
plugin :tmp_restart
