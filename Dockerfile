FROM ruby:3.3.4

WORKDIR /app

# Dépendances système
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    postgresql-client \
    yarn \
    libvips

# Installer les gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copier le reste de l'app
COPY . .

# Créer le dossier tmp/pids pour Puma
RUN mkdir -p tmp/pids

CMD ["bash", "-c", "bundle exec puma -C config/puma.rb"]
EXPOSE 3000
