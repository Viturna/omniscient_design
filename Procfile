web: bundle exec puma -C config/puma.rb
js: yarn build --watch
css: yarn build:css --watch
release: bundle exec rails db:migrate && RAILS_ENV=production bundle exec rails assets:precompile
