

# import .mk

install:
	bundle install
	rails assets:precompile

dev:
	rails assets:precompile
	rails s -p 3001

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
