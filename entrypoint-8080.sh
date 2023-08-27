#!/bin/bash

set -x

#source .env.sh
source .envrc

# serbe in prod per non imputtanire gli assets!
export RAILS_ENV=${RAILS_ENV:-production}
export RAILS_SERVE_STATIC_FILES=true
export RAILS_LOG_TO_STDOUT=yesplease

echo '------------------------------------------------------'
echo "$0 v$VER"
echo "RAILS_ENV: $RAILS_ENV"
echo "DB HOST:   $DATABASE_HOST"
echo "RAILS_MASTER_KEY:  ${RAILS_MASTER_KEY:1:4}.. (removeme when it works)"
echo '------------------------------------------------------'

#export RAILS_MASTER_KEY=0b6df96739181851e3b696c3f88714bf

#echo DISK_FILOSOFIA="dev:$RAILS_STORAGE_BACKEND_DEV/prod:$RAILS_STORAGE_BACKEND_PROD"
# Thois is needed in PROD
# Articolo figo: https://stackoverflow.com/questions/49440304/rails-asset-is-not-present-in-asset-pipeline-when-using-image-tag
#rails assets:precompile
bundle exec rails assets:precompile

rake db:migrate
rake db:seed

bundle exec rails s -p 8080 -b 0.0.0.0
