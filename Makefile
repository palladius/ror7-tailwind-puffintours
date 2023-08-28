

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
