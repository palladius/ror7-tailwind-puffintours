#!/bin/bash
set -e

if [ -f .envrc ]; then
  source .envrc
fi

# Materialize GCP service account key from GCP_SA_JSON_BASE64 when running on Render / external hosts
if [ -n "${GCP_SA_JSON_BASE64:-}" ]; then
  echo "$GCP_SA_JSON_BASE64" | base64 -d > /tmp/gcp-sa.json
  export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp-sa.json
  echo "🔑 Decoded GCP_SA_JSON_BASE64 into /tmp/gcp-sa.json"
fi

export RAILS_ENV=${RAILS_ENV:-production}
export RAILS_SERVE_STATIC_FILES=true
export RAILS_LOG_TO_STDOUT=yesplease
export PORT=${PORT:-8080}
export RAILS_MAX_THREADS=${RAILS_MAX_THREADS:-2}
export MALLOC_ARENA_MAX=${MALLOC_ARENA_MAX:-2}
export RUBY_GC_HEAP_GROWTH_FACTOR=${RUBY_GC_HEAP_GROWTH_FACTOR:-1.1}
export RUBY_GC_MALLOC_LIMIT=${RUBY_GC_MALLOC_LIMIT:-16000000}
export RUBY_GC_OLDMALLOC_LIMIT=${RUBY_GC_OLDMALLOC_LIMIT:-16000000}
export RUBY_YJIT_ENABLE=${RUBY_YJIT_ENABLE:-0}

for jemalloc_path in /usr/lib/x86_64-linux-gnu/libjemalloc.so.2 /usr/lib/aarch64-linux-gnu/libjemalloc.so.2 /usr/lib/libjemalloc.so.2; do
  if [ -f "$jemalloc_path" ]; then
    export LD_PRELOAD="$jemalloc_path"
    echo "🧠 Enabled jemalloc allocator: $LD_PRELOAD"
    break
  fi
done

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
