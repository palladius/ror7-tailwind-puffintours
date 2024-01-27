source "https://rubygems.org"

#ruby File.read(".ruby-version").strip
ruby '3.2.1'

# Riccardo
gem 'sqlite3', '~> 1.7', '>= 1.7.1'
gem 'acts-as-taggable-on', '~> 10.0'
# https://gist.github.com/hilava/e8c18654f49f32db0a24ade4a3884f85
#gem 'acts_as_votable' # https://github.com/ryanto/acts_as_votable
gem 'acts_as_votable', '~> 0.14.0'
gem 'lolcat'
#gem "google-cloud-storage", "~> 1.11", require: false # for ActiveStorage to GCP
gem 'google-cloud-storage', '~> 1.48', '>= 1.48.1', require: false
  # Questi due NON servono servono solo per il file in bin/
  gem 'google-cloud-env', '>= 2.1', require: false # Per capire se sei su GCE o CRun..
  gem 'google-apis-iamcredentials_v1', '~> 0.18.0', require: false
  gem 'google-apis-iamcredentials_v2', '~> 9001.0', require: false # may 2021
gem 'googleauth', '~> 1.9', '>= 1.9.2' # if not gives error
gem "chartkick" # for charts on main page
  gem "groupdate" # to help chartkick do some real Date Grouping magic
  gem 'active_median' # to help ChjartKick too: see https://geekhmer.github.io/blog/2015/05/02/ruby-on-rails-charting-with-chartkick-gem/
  #gem 'chartjs-ror' # This is just Codey autocompletion :)
gem 'langchainrb', '~> 0.9.0'  # GenAI
gem 'rack-cors'
# /Riccardo

#gem "rails", "~> 7.0"
gem 'rails', '~> 7.1', '>= 7.1.3'
gem 'pg', '~> 1.5', '>= 1.5.4'
gem 'puma', '~> 6.4', '>= 6.4.2'
gem "bootsnap", "~> 1.13", require: false
gem 'devise', '~> 4.9', '>= 4.9.3'
gem "omniauth-facebook", "~> 9.0"
gem "omniauth-github", "~> 2.0"
gem 'omniauth-google-oauth2', '~> 1.1', '>= 1.1.1'
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "cancancan", "~> 3.4"
gem "ransack", "~> 3.2"
gem "pagy", "~> 5.10"
gem "image_processing", "~> 1.2"
gem "faker", "~> 2"

# Front-end
gem "sprockets-rails", "~> 3.4"
gem "jsbundling-rails", "~> 1.0"
gem "cssbundling-rails", "~> 1.1"
gem "turbo-rails", "~> 1.3"
gem "heroicon", "~> 1.0"

group :development do
  gem "web-console"
  gem "debug"
  gem "dotenv-rails"

  # Riccardo START
  # autoreload https://stackoverflow.com/questions/35489477/how-to-enable-automatic-code-reloading-in-rails
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'listen'
  gem 'guard'
  gem 'guard-zeus'
  gem 'rack-livereload'
  gem 'rails_live_reload'
  # Riccardo DEV  END

end

# Me l'ha detto Bard per trovare i video attached..
#gem 'trix-rails', require: 'trix'
gem 'html-pipeline'
gem 'html-pipeline-trix-video' # BAD: https://github.com/HazelGrant/html-pipeline-trix-video
gem 'html-pipeline-youtube'
gem 'html-pipeline-vimeo'

# less useful but nice:
gem 'html-pipeline-wiki-link' # HTML::Pipeline::MarkdownFilter,
gem 'commonmarker'
gem 'rouge'
gem 'sanitize'
gem 'rinku'
gem 'gemoji'
#HTML::Pipeline::WikiLinkFilter
#gem "html-pipeline-linkify_github" #   HTML::Pipeline::LinkifyGitHubFilter
#EmojiFilter
#MentionFilter
#ImageMaxWidthFilter

gem "tailwindcss-rails", "~> 2.3"
