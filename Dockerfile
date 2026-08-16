# syntax = docker/dockerfile:1

# === STAGE 1: Builder ===
# Utilisation de l'image Ruby complète pour compiler tout ce qu'il faut
FROM ruby:3.3.4 AS builder

WORKDIR /app

# Installer Node.js 22, Yarn et dépendances systèmes pour la compilation
RUN apt-get update -qq && \
    apt-get install -y curl build-essential libpq-dev libvips pkg-config && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

# Configurer Bundler pour la production (ignore les gems de test/dev)
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Installer les gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Installer les dépendances JS
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copier le code source de l'application
COPY . .

# Précompiler les assets (CSS/JS) et bootsnap
# Nettoyage immédiat des dossiers inutiles (node_modules, caches) pour gagner de la place
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile && \
    bundle exec bootsnap precompile --gemfile app/ lib/ && \
    rm -rf node_modules tmp/cache

# === STAGE 2: Final Runner ===
# Utilisation de l'image "slim" ultra-légère pour le runtime final
FROM ruby:3.3.4-slim AS final

WORKDIR /app

# Variables d'environnement pour la production
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_LOG_TO_STDOUT="true"

# Installer uniquement les dépendances systèmes strictes requises pour lancer l'app
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    postgresql-client libvips curl tzdata && \
    rm -rf /var/lib/apt/lists/*

# Créer un utilisateur non-root pour la sécurité
RUN useradd -m --shell /bin/bash rubyuser && \
    chown -R rubyuser:rubyuser /app
USER rubyuser

# Récupérer UNIQUEMENT les gems compilées et le code nettoyé de l'étape "builder"
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=rubyuser:rubyuser /app /app

# Créer les dossiers nécessaires pour Puma/Rails au cas où
RUN mkdir -p tmp/pids tmp/cache log

EXPOSE 3000

CMD ["bash", "-c", "bundle exec puma -C config/puma.rb"]
