# syntax=docker/dockerfile:1
# Multi-stage Dockerfile for Puffin Tours (Rails 8.1 + Ruby 3.4.5-slim)
# Stage 1 (builder): installs compilers + Node/Yarn, compiles native gems & precompiles assets.
# Stage 2 (runtime): minimal Debian slim with only runtime shared libraries + jemalloc.

ARG RUBY_VERSION=3.4.5
FROM ruby:${RUBY_VERSION}-slim AS builder

ENV NODE_MAJOR=20 \
    APP_HOME=/riccardo-rails-app \
    RAILS_ENV=production \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    curl ca-certificates gnupg build-essential pkg-config libpq-dev libyaml-dev \
    && curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - \
    && curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/yarn-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq && apt-get install --no-install-recommends -y nodejs yarn \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $APP_HOME

# 1. Install production Ruby gems and strip cached .gem/.c/.o build artifacts
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
    && bundle install --jobs 4 --retry 3 \
    && rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/ -name "*.c" -delete \
    && find /usr/local/bundle/ -name "*.o" -delete

# 2. Install JS dependencies for esbuild & Tailwind
COPY package.json yarn.lock ./
RUN yarn install --check-files

# 3. Copy application source & precompile assets + bootsnap bytecode cache
COPY . .
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile \
    && bundle exec bootsnap precompile app/ lib/ \
    && rm -rf node_modules tmp/cache /root/.cache /usr/local/share/.cache


# ==============================================================================
# Stage 2: Minimal Runtime Image (no gcc, no clang/llvm, no nodejs/yarn!)
# ==============================================================================
FROM ruby:${RUBY_VERSION}-slim AS runtime

ENV APP_HOME=/riccardo-rails-app \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_MAX_THREADS=2 \
    MALLOC_ARENA_MAX=2 \
    RUBY_GC_HEAP_GROWTH_FACTOR=1.1 \
    RUBY_GC_MALLOC_LIMIT=16000000 \
    RUBY_GC_OLDMALLOC_LIMIT=16000000 \
    RUBY_YJIT_ENABLE=0

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    curl ca-certificates libjemalloc2 libpq5 imagemagick \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR $APP_HOME

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder $APP_HOME $APP_HOME

EXPOSE 10000 8080
CMD ["/riccardo-rails-app/entrypoint-8080.sh"]
