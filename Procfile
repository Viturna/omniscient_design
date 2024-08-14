web: bin/rails server -p $PORT
web: bundle exec puma -C config/puma.rb
postdeploy: rails db:migrate && rails db:seed
