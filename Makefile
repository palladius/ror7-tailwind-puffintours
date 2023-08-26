

# import .mk

install:
	bundle install
	rails assets:precompile

dev:
	rails s -p 3001
