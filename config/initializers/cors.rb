# https://stackoverflow.com/questions/76295494/how-can-i-fix-the-cors-policy-error-im-getting-while-trying-to-run-my-react-a
# https://www.stackhawk.com/blog/rails-cors-guide/
#
# crossorigin="anonymous"
#
#ENV['CORS_ORIGINS'] = 'https://domain.first.com, http://another.origin.io'

puffintours_origins = [
  "https://puffintours-prova-con-secret-rjjr63dzrq-uc.a.run.app:443/",
  "https://puffintours-prod-rjjr63dzrq-ew.a.run.app:443/",
  "http://localhost:8080/",
  "http://localhost:3000/",
  "http://127.0.0.1:8080/",
  "http://127.0.0.1:3000/",
]

Rails.application.config.middleware.use Rack::Cors do
  allow do
    origins '*'
    resource '*',
      :headers => :any,
      :methods => [:get, :post, :delete, :put, :options]
  end
end

# moved to config.ru

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins '*'
#     resource '*', headers: :any, methods: [:get, :post, :patch, :put]
#   end
# end

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins 'http://localhost:8080' , # /http:\/\/example\.com/
#     #origins puffintours_origins  # 'http://localhost:8080' , # /http:\/\/example\.com/
# # https://stackoverflow.com/questions/41589352/ruby-on-rails-rack-cors-multiple-origins-with-different-resources
# #    origins ENV['CORS_ORIGINS'].split(',').map { |origin| origin.strip }

#     resource '/articles',
#       :headers => :any,
#       :methods => [:post]

#     resource '*', headers: :any, methods: [:get, :post]

#     resource '*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head],
#       expose: ['X-Total-Count']
#     # resource '/users',
#     #   headers: :any,
#     #   methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end
