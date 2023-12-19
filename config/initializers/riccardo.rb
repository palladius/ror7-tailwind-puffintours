

# Google client_id
AppName = 'Puffin Tours'
AppEmoji = '🐧🧳'
AppVersion = File.read('VERSION').chomp

ProdAppUrl = 'https://puffintours-prod-rjjr63dzrq-ew.a.run.app/'
GithubCodeUrl =  'https://github.com/palladius/ror7-tailwind-puffintours/'

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

# from https://acuments.com/uploading-audio-video-pdf-with-action-text.html
Rails.application.config.after_initialize do
  ActionText::ContentHelper.allowed_attributes.add 'style'
  ActionText::ContentHelper.allowed_attributes.add 'controls'
  ActionText::ContentHelper.allowed_attributes.add 'poster'

  ActionText::ContentHelper.allowed_tags.add 'video'
  ActionText::ContentHelper.allowed_tags.add 'audio'
  ActionText::ContentHelper.allowed_tags.add 'source'
  ActionText::ContentHelper.allowed_tags.add 'embed'
  ActionText::ContentHelper.allowed_tags.add 'iframe'
end


$pipeline = HTML::Pipeline.new [
                  # the ones I needed
                HTML::Pipeline::TrixVideoFilter,
                HTML::Pipeline::VimeoFilter,
                HTML::Pipeline::YoutubeFilter,
                # Nice to have. Note: if you add these it stops being
                # HTNML and it becomes Nokogiri parsed -> fails.
                #HTML::Pipeline::MarkdownFilter, #requires commonmarker
                #HTML::Pipeline::SyntaxHighlightFilter,
                #HTML::Pipeline::SanitizationFilter,
                #HTML::Pipeline::AutolinkFilter,
                HTML::Pipeline::MentionFilter,
                HTML::Pipeline::ImageMaxWidthFilter,
                ]

                # Errors:
                #HTML::Pipeline::EmojiFilter, # GIVES ERROR
                #HTML::Pipeline::LinkifyGitHubFilter, anchored to ruby 2 :/
                #HTML::Pipeline::WikiLinkFilter,
