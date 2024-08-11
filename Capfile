# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Load the SCM plugin appropriate to your project:
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
require 'capistrano/rails'
require 'capistrano/rbenv'
require 'capistrano/puma'

# Set up plugins
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

# Configure rbenv
set :rbenv_type, :user
set :rbenv_ruby, '3.3.4'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
