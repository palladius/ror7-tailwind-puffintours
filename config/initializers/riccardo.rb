

# Google client_id
AppName = 'Puffin Tours'
AppEmoji = '🐧🧳'
AppVersion = File.read('VERSION').chomp
GcsBucket = ENV.fetch('BUCKET', 'puffin-tours-public')

ProdAppUrl = 'https://ror7-tailwind-puffintours.onrender.com/'
CloudRunProdAppUrl = 'https://puffintours-prod-rjjr63dzrq-ew.a.run.app/'
GithubCodeUrl =  'https://github.com/palladius/ror7-tailwind-puffintours/'

# TODO move to ENV :)
Rails.application.config.hosts << 'puffintours-prova-con-secret-rjjr63dzrq-uc.a.run.app'
Rails.application.config.hosts << 'puffintours-prod-rjjr63dzrq-ew.a.run.app'
Rails.application.config.hosts << 'puffintours-prod-907790253572.europe-west1.run.app'
# Added with DNS - oh wow!
Rails.application.config.hosts << 'pt.palladius.it'
Rails.application.config.hosts << 'tours.palladius.it'
Rails.application.config.hosts << 'puffintours.palladius.it'
Rails.application.config.hosts << '.onrender.com'
Rails.application.config.hosts << ENV['RENDER_EXTERNAL_HOSTNAME'] if ENV['RENDER_EXTERNAL_HOSTNAME'].present?

# TODO Add an ENV cosi glielo do da ENV e vaffanbagno!
# Remove the rescue after it works..
Rails.application.config.hosts << ENV['APP_CLOUDRUN_URL'] if ENV.fetch('APP_CLOUDRUN_URL', nil)  rescue :boh

# Se no non va in localhost :)
#E, [2023-10-22T10:06:40.314767 #30] ERROR -- : [ActionDispatch::HostAuthorization::DefaultResponseApp] Blocked host: puffintours-prod-rjjr63dzrq-ew.a.run.app
Rails.application.config.hosts << "localhost"
Rails.application.config.hosts << "127.0.0.1"
Rails.application.config.hosts << ".example.com"
Rails.application.config.hosts << IPAddr.new("10.0.0.0/8")
Rails.application.config.hosts << IPAddr.new("172.16.0.0/12")
Rails.application.config.hosts << IPAddr.new("192.168.0.0/16")

# https://github.com/mbleigh/acts-as-taggable-on?search=1
ActsAsTaggableOn.force_lowercase = true

# Prevent Pagy::OverflowError (500) when requesting out-of-range ?page=N
require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page

# per fare andare i video su Trix: https://stackoverflow.com/questions/56316549/how-to-display-embed-video-with-actiontext
Rails.application.config.to_prepare do

  # Initialize allowed tags if nil
  ActionText::ContentHelper.allowed_tags ||= %w[
    div p br blockquote pre h1 h2 h3 h4 h5 h6
    ul ol li strong em a img code iframe
    audio video source embed
  ]

  # Initialize allowed attributes if nil
  #   # For embedded content security
  ActionText::ContentHelper.allowed_attributes ||= %w[
    href src class id width height controls
    poster preload style frameborder allowfullscreen
  ]

end


# from https://acuments.com/uploading-audio-video-pdf-with-action-text.html

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

ENABLE_CURSOR_EXPERIMENTS = false
PUFFIN_TOURS_GEMINI_API_KEY = ENV.fetch('PUFFIN_TOURS_GEMINI_API_KEY', nil)
GOOGLE_APPLICATION_CREDENTIALS = ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS', nil)
GEMINI_MODEL = ENV.fetch('GEMINI_MODEL', 'gemini-2.5-flash')

GeminiAiVisionClientLogan = if PUFFIN_TOURS_GEMINI_API_KEY.present?
  Gemini.new(
    credentials: {
      service: 'generative-language-api',
      api_key: PUFFIN_TOURS_GEMINI_API_KEY,
      version: 'v1beta',
    },
    options: { model: GEMINI_MODEL, server_sent_events: true }
  ) rescue nil
end

GeminiAiVisionClientLocalADC = if GOOGLE_APPLICATION_CREDENTIALS.present? && File.exist?(GOOGLE_APPLICATION_CREDENTIALS)
  Gemini.new(
    credentials: {
      service: 'vertex-ai-api',
      file_path: GOOGLE_APPLICATION_CREDENTIALS,
      region: 'us-east4',
      project_id: ENV.fetch('PROJECT_ID', 'puffin-tours'),
    },
    options: { model: GEMINI_MODEL, server_sent_events: true }
  ) rescue GeminiAiVisionClientLogan
else
  GeminiAiVisionClientLogan
end

# An Env to force the clean interface. DFLT=FALSE :)
DEBUG = ENV.fetch('DEBUG', 'false').downcase == 'true'
# An Env to force the clean interface. DFLT=TRUE! :)
CLEAN_INTERFACE_ENABLED = ! DEBUG # ENV.fetch('CLEAN_INTERFACE_ENABLED', 'true').downcase == 'true'


puts("🐧" * 40)
puts("🐧 ♊️🔑 PUFFIN_TOURS_GEMINI_API_KEY=#{PUFFIN_TOURS_GEMINI_API_KEY}")
puts("🐧 ♊️🔑 GOOGLE_APPLICATION_CREDENTIALS=#{GOOGLE_APPLICATION_CREDENTIALS}")
puts("🐧 ♊️🔑 DEBUG=#{DEBUG}")
puts("🐧" * 40)
