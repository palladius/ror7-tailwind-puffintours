# Dockerfile for Puffin Tours (Rails 8.1 + Ruby 3.4.5 + Node 20 + Tailwind)
FROM ruby:3.4.5

ENV NODE_MAJOR=20
ENV APP_HOME=/riccardo-rails-app
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ENV BUNDLE_WITHOUT="development:test"
ENV RAILS_MAX_THREADS=2
ENV MALLOC_ARENA_MAX=2
ENV RUBY_GC_HEAP_GROWTH_FACTOR=1.1
ENV RUBY_GC_MALLOC_LIMIT=16000000
ENV RUBY_GC_OLDMALLOC_LIMIT=16000000
ENV RUBY_YJIT_ENABLE=0

RUN apt-get update && apt-get install -y \
    curl build-essential libjemalloc2 libvips libmariadb-dev libpq-dev libclang-dev clang llvm-dev \
    && curl -sSL https://deb.nodesource.com/setup_20.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/yarn-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y nodejs yarn \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $APP_HOME

# 1. Cache Ruby gems layer (excluding development & test gems to save RAM and disk)
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
    && bundle install --jobs 4 --retry 3

# 2. Cache Node / Yarn packages layer
COPY package.json yarn.lock ./
RUN yarn install --check-files

# 3. Copy application source
COPY . .

# 4. Precompile assets at build time using Rails 8 SECRET_KEY_BASE_DUMMY=1 and remove node_modules/caches after build
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile \
    && rm -rf node_modules /root/.cache /usr/local/share/.cache /tmp/*

EXPOSE 10000 8080
CMD ["/riccardo-rails-app/entrypoint-8080.sh"]
