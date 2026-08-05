FROM ruby:3.3.4

WORKDIR /app

# Dépendances système (nodejs, npm pour yarn, libvips, postgresql-client)
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    npm \
    postgresql-client \
    libvips \
    && npm install -g yarn

# Installer les gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copier le reste de l'app
COPY . .

# Installer les dépendances JS et précompiler les assets
RUN yarn install
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile

# Créer le dossier tmp/pids pour Puma
RUN mkdir -p tmp/pids

CMD ["bash", "-c", "bundle exec puma -C config/puma.rb"]
EXPOSE 3000
