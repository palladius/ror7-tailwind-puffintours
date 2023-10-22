

# Google client_id
AppName = 'Puffin Tours'
AppEmoji = '🐧🧳'


# TODO move to ENV :)
#Rails.application.config.hosts << "dhh-vanilla-701-dev-cdlu26pd4q-oa.a.run.app"
Rails.application.config.hosts << 'puffintours-prova-con-secret-rjjr63dzrq-uc.a.run.app'
Rails.application.config.hosts << 'puffintours-prod-rjjr63dzrq-ew.a.run.app'
#Rails.application.config.hosts << 'puffintours-prod-rjjr63dzrq-ew.a.run.app'

# TODO Add an ENV cosi glielo do da ENV e vaffanbagno!
Rails.application.config.hosts << ENV['APP_CLOUDRUN_URL'] if ENV.fetch('APP_CLOUDRUN_URL') # rescue :boh

# Se no non va in localhost :)
#E, [2023-10-22T10:06:40.314767 #30] ERROR -- : [ActionDispatch::HostAuthorization::DefaultResponseApp] Blocked host: puffintours-prod-rjjr63dzrq-ew.a.run.app
Rails.application.config.hosts << "localhost"

# https://github.com/mbleigh/acts-as-taggable-on?search=1
ActsAsTaggableOn.force_lowercase = true
