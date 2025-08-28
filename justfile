# import .mk

install:
	# Me l'ha detto l'AI cosi fixo langchainrb
	bundle config build.unicode --with-cflags="-Wno-incompatible-function-pointer-types"
	bundle install
	rails assets:precompile

fix-arel:
	bundle update rails activerecord activesupport
	bin/rails tmp:clear
	bin/rails log:clear

cool-stuff:
	bundle exec annotate --models
###########
# Smart rails s :)
# "app/assets/builds/application.js":
# 	echo This aint perfect but close enough..
# 	rails assets:precompile

run-dev: # "app/assets/builds/application.js"
	rails s

dev:
	rails assets:precompile
	DEBUG=true bin/dev

# dev:
# 	rails assets:precompile
# 	#rails s -p 3000
# 	bin/dev
prod: run-prod

run-prod:
	echo Should connect to PostgreS if you set up user/pass/host/.. correctly
	source .envrc && ./entrypoint-8080.sh

credential-edits:
	EDITOR='code --wait' rails credentials:edit


docker-build:
	docker build -t puffintours:latest .

# "Missing `secret_key_base` for '#{Rails.env}' environment, set this string with `bin/rails credentials:edit`"
docker-run-prod:
	# TODO Add also DB stuff
	docker run -it -p 8080:8080 \
	  -e DATABASE_HOST="$(DATABASE_HOST)" \
	  -e DATABASE_NAME="$(DATABASE_NAME)" \
	  -e DATABASE_USER="$(DATABASE_USER)" \
	  -e DATABASE_PASS="$(DATABASE_PASS)" \
	  -e RAILS_MASTER_KEY="$(RAILS_MASTER_KEY)" \
	puffintours:latest


clean:
	#https://stackoverflow.com/questions/9335803/confusion-about-rake-assetsclean-cleanup-on-the-asset-pipeline-in-rails
	echo Cleaning up the Assets Pipeline.
	rake assets:clean
	rake assets:clobber
	# Riccardo says so
	rm -rf node_modules/ app/assets/builds/*

# copiato da GENAI KIDS
# https://docs.npmjs.com/updating-packages-downloaded-from-the-registry
npm-update:
	npm outdated
	yarn upgrade

# learn and script with $1
search-string-with-ack:
	bin/search-string-in-repo.sh fetch-api-data


test-gemini-prod:
	bin/test-gemini-prod.sh

make-admin EMAIL:
    #!/usr/bin/env bash
    set -euxo pipefail
    bin/rails runner "user = User.find_by(email: '{{EMAIL}}'); if user; user.update(is_admin: true); puts 'User {{EMAIL}} is now an admin.'; else; puts 'User not found.'; end"


# New Gemini feature from 28aug25 - auto edit!
gemini:
  gemini -c --approval-mode auto_edit

# List latest 10 CB builds, possible the first might still be running
cloud-build-list:
    gcloud builds list --project=puffin-tours --limit=10

# Show the log of a specific Cloud Build, eg 7c82188e-485a-4735-a70d-fb303fbfe5a0
cloud-build-show-log build_id:
    @echo "Showing log for build ID: {{build_id}}. Use --stream to follow the log indefinitely (you can do it, but I want Gemini NOT to do it)."
    gcloud builds log {{build_id}} --project=puffin-tours

# show Cloud Run logs
cloud-run-logs:
    @echo "☁️  Fetching logs for Cloud Run environment..."
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=puffintours-prod-rjjr63dzrq-ew.a.run.app" --project=puffin-tours --limit=100 --format="value(timestamp, severity, textPayload)"

# Shows git logs in timestamped way
git-logs-timestamped:
    git log --pretty=format:'%h %ad | %s%d [%an]' --date=iso -n 10