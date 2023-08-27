

# import .mk

install:
	bundle install
	rails assets:precompile

dev:
	rails assets:precompile
	rails s -p 3001
