

# Google client_id
AppName = 'Puffin Tours'
AppEmoji = '🐧🧳'
AppVersion = File.read('VERSION').chomp

# TODO move to ENV :)
#Rails.application.config.hosts << "dhh-vanilla-701-dev-cdlu26pd4q-oa.a.run.app"
Rails.application.config.hosts << 'puffintours-prova-con-secret-rjjr63dzrq-uc.a.run.app'
Rails.application.config.hosts << 'puffintours-prod-rjjr63dzrq-ew.a.run.app'
#Rails.application.config.hosts << 'puffintours-prod-rjjr63dzrq-ew.a.run.app'

# TODO Add an ENV cosi glielo do da ENV e vaffanbagno!
# Remove the rescue after it works..
Rails.application.config.hosts << ENV['APP_CLOUDRUN_URL'] if ENV.fetch('APP_CLOUDRUN_URL', nil)  rescue :boh

# Se no non va in localhost :)
#E, [2023-10-22T10:06:40.314767 #30] ERROR -- : [ActionDispatch::HostAuthorization::DefaultResponseApp] Blocked host: puffintours-prod-rjjr63dzrq-ew.a.run.app
Rails.application.config.hosts << "localhost"

# https://github.com/mbleigh/acts-as-taggable-on?search=1
ActsAsTaggableOn.force_lowercase = true

# per fare andare i video su Trix: https://stackoverflow.com/questions/56316549/how-to-display-embed-video-with-actiontext
Rails.application.config.to_prepare do
  ActionText::ContentHelper.allowed_tags << "iframe"
  # oppure prova: <script async src="//www.instagram.com/embed.js"></script>).html_safe
  # #<%= raw your_action_text_object.to_plain_text %>
end

$pipeline = HTML::Pipeline.new [
                HTML::Pipeline::TrixVideoFilter,
                HTML::Pipeline::VimeoFilter,
                HTML::Pipeline::YoutubeFilter,
              ]
