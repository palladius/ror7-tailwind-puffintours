#!/bin/bash

#####################################################################################################
# Since CB doesnt have access to a number of vars, I'm trying to add them as secret
# AND THEN retrieve them from CB. If it works locally, it should hopefully also work remotely
# As long as CB has access to those secrets (CB SA was enabled to read secrets).
#####################################################################################################

export DEPLOY_VERSION='1.0.1'
#direnv allow "$(git rev-parse --show-toplevel)"
# if it fails no probs... yet
. .env.sh

set -euo pipefail

################################################
# ENV set
################################################
export APP_NAME='puffintours'
export GIT_STATE="$(git rev-list -1 HEAD --abbrev-commit)"
export GIT_COMMIT_SHA="$(git rev-parse HEAD)" # big commit
export GIT_SHORT_SHA="${GIT_COMMIT_SHA:0:7}" # first 7 chars: Riccardo reproducing what CB does for me.
export APP_VERSION="$(cat VERSION)"
#- "${_REGION}-docker.pkg.dev/${PROJECT_ID}/${APP_NAME}/${APP_NAME}:sha-$SHORT_SHA"

# get from secret manager
#SECRET_REGION=$(gcloud secrets versions access latest --secret=PUFFINTOURS_REGION)

# Derived info
CLOUDRUN_PROJECT_ID="$PROJECT_ID"
# VER non lo posso calcolare da CB vanilla, serve un shell script :/
UPLOADED_IMAGE_WITH_VER="${GCLOUD_REGION}-docker.pkg.dev/${PROJECT_ID}/${APP_NAME}/${APP_NAME}:v$APP_VERSION"
UPLOADED_IMAGE_WITH_SHA="${GCLOUD_REGION}-docker.pkg.dev/${PROJECT_ID}/${APP_NAME}/${APP_NAME}:sha-$GIT_SHORT_SHA"

# $1 can be unbound
if [ latest = "${1:-sthElse}" ]; then
  echo Overriding the version to LATEST:
  export UPLOADED_IMAGE_WITH_SHA="${GCLOUD_REGION}-docker.pkg.dev/${PROJECT_ID}/${APP_NAME}/${APP_NAME}:latest"
fi

echo "---- DEBUG  ----"
echo "DEPLOY_VERSION:   $DEPLOY_VERSION"
echo "APP_VERSION:   $APP_VERSION"
echo "GIT_SHORT_SHA: $GIT_SHORT_SHA"
echo "UPLOADED_IMAGE_WITH_SHA: $UPLOADED_IMAGE_WITH_SHA"
echo "---- /DEBUG ----"

# TODO(ricc): As a future iteration, tag and push the v0.1.2 too and use that for CRun
#docker tag "$TAGGED_IMAGE" "$TAGGED_IMAGE:v`./version.sh`"

# copy locally. Changing name for localhost testing :)
#gsutil cp "gs://${PROJECT_ID}-state/.env.gcs" .envrc.from-gcs

# source = now I have all info here even without direnv :)
# This exposes REGION, APP_ENV, APP_VERSION, REGION, GIT_STATE
#source .envrc.from-gcs

set -x

#################################################################
# TODO(ricc): remove the clutter when this is proven to work.
#################################################################
# Note from Marc: this is not needed since its baked into CB
# --set-env-vars="APP_VERSION=$APP_VERSION" \
# Not used anymore
#--set-env-vars="APPLICATION_DEFAULT_CREDENTIALS=/sa.json" \
#  --update-secrets=PUFFINTOURS_OAUTH_CLIENT_SECRET_JSON_FILE_CONTENT=PUFFINTOURS_OAUTH_CLIENT_SECRET_JSON_FILE_CONTENT:latest \
#################################################################

# Ho creato questo: (vedi https://console.cloud.google.com/run/detail/europe-west6/${APP_NAME}-poor-cb/yaml/view?hl=IT&project=ror-goldie )
# limits:
#             cpu: 2000m
#             memory: 2Gi

gcloud --project "$CLOUDRUN_PROJECT_ID" \
    beta run deploy ${APP_NAME}-prod \
      --image    "$UPLOADED_IMAGE_WITH_VER" \
      --platform managed \
      --memory "2048Mi" \
      --region   "$GCLOUD_REGION" \
      --set-env-vars='description=created-from-bin-slash-cb-push-to-cloudrun-sh' \
      --set-env-vars='fav_color=purple' \
      --set-env-vars="GIT_STATE=$GIT_STATE" \
      --set-env-vars="APP_VERSION=$APP_VERSION" \
      --set-env-vars="SECRET_KEY_BASE=TODO" \
      --set-env-vars="RAILS_MASTER_KEY=TODO" \
      --set-env-vars="RAILS_ENV=production" \
      --set-env-vars="RAILS_SERVE_STATIC_FILES=true" \
      --set-env-vars="MESSAGGIO_OCCASIONALE=This is a public repo, watch the ids you disseminate here...." \
      --set-env-vars="RAILS_LOG_TO_STDOUT=yesplease" \
      --allow-unauthenticated

#      --update-secrets=PUFFINTOURS_SECRET_KEY=PUFFINTOURS_SECRET_KEY:latest \
#      --service-account="puffintours-docker-runner@$PROJECT_ID.iam.gserviceaccount.com" \


# make sure we exit 0 with a string (set -e guarantees this)
echo All is Done.
