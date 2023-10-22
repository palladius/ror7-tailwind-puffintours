# Dockerfile copiato da ror-rails-goldie copialo da la..
# 2023-10-22 v0.2 Moved from node_10 to node_18
FROM ruby:3.2.1

ENV APP_HOME /riccardo-rails-app

# Added for YARN or it wont work...
# https://medium.com/@yuliaoletskaya/how-to-start-your-rails-app-in-a-docker-container-9f9ce29ff6d6

# TODO   Node.js 10.x is no longer actively supported!

# dal 1.1. voglio anche PGsql: # sudo apt install postgresql postgresql-contrib libpq-dev
# Dal 1.0.6 voglio anche libvips che se no ciocca.
RUN apt-get update
RUN apt-get install -y \
  curl \
  build-essential \
  libvips \
  libmariadb-dev \
  libpq-dev &&\
  curl -sSL https://deb.nodesource.com/setup_18.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn

# We specify everything will happen within the /app folder inside the container
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

#########################################################################
# 1. We copy these files from our current application to the /app container
COPY Gemfile Gemfile.lock ./
# We install all the dependencies
RUN bundle install

# From Yulia, make yarn work
#COPY package.json .
# Woohoo sono YARNLESS!!!
#COPY yarn.lock .


#### CACHE ENDS HERE :)

# We copy all the files from our current application to the /app container
COPY . .

# TODO maybe we can do this BEFORE copy? I'm ignorant on YARN...
#RUN yarn install --check-files

ENV RAILS_ENV production

# Lets try precompilation in the Docker image so it should alreay work.. but mayb e it needs a var which is not
# available to me
# Wait!!! to do this you need a PWD / ENV which is not safe to have inside docker - let me remove this instead.
#RUN RAILS_ENV=production rails assets:precompile

# We expose the port
EXPOSE 8080
# Start the main process: $ rails server -b 0.0.0.0
#CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080"]
CMD ["/riccardo-rails-app/entrypoint-8080.sh"]
