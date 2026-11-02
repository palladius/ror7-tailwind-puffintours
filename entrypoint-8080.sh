#!/bin/bash
set -e

if [ -f .envrc ]; then
  source .envrc
fi

export RAILS_ENV=${RAILS_ENV:-production}
export RAILS_SERVE_STATIC_FILES=true
export RAILS_LOG_TO_STDOUT=yesplease
export PORT=${PORT:-8080}

echo "------------------------------------------------------"
echo "🐧 Starting Puffin Tours (RAILS_ENV=$RAILS_ENV, PORT=$PORT)"
echo "DB HOST: ${DATABASE_HOST:-via DATABASE_URL}"
echo "------------------------------------------------------"

# Only precompile at startup if assets were not already baked into the image
if ! ls public/assets/.sprockets-manifest-*.json >/dev/null 2>&1; then
  echo "Precompiling assets..."
  RAILS_ENV=production bundle exec rails assets:precompile
fi

# Only run blocking db:migrate before server start if explicitly requested via RUN_DB_MIGRATE=true.
# By default, Puma binds to $PORT immediately and checks pending migrations in config/puma.rb on_booted.
if [ "${RUN_DB_MIGRATE:-false}" = "true" ]; then
  RAILS_ENV=production bundle exec rake db:migrate
fi

if [ "${RUN_DB_SEED:-false}" = "true" ]; then
  RAILS_ENV=production bundle exec rake db:seed
fi

exec bundle exec rails s -p "$PORT" -b 0.0.0.0
