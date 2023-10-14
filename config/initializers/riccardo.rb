

# Google client_id
AppName = 'Puffin Tours'
AppEmoji = '🐧🧳'


# TODO move to ENV :)
#Rails.application.config.hosts << "dhh-vanilla-701-dev-cdlu26pd4q-oa.a.run.app"
Rails.application.config.hosts << 'puffintours-prova-con-secret-rjjr63dzrq-uc.a.run.app'
# Se no non va in localhost :)
Rails.application.config.hosts << "localhost"

# https://github.com/mbleigh/acts-as-taggable-on?search=1
ActsAsTaggableOn.force_lowercase = true
