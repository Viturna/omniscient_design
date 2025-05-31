FROM ruby:3.3.4

WORKDIR /app

# Dépendances
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client yarn

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Pas de db:migrate ici !
# PAS DE : bundle exec rails db:migrate
# PAS DE : bundle exec rails assets:precompile
RUN mkdir -p tmp/pids
CMD ["bash", "-c", "bundle exec puma -C config/puma.rb"]
