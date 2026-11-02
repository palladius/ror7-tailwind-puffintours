require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsRalixTailwind
  class Application < Rails::Application
    # Load Rails 8 defaults
    config.load_defaults 8.0

    # This tells Rails to serve error pages from the app itself, rather than using static error pages in public/
    config.exceptions_app = self.routes

    # Riccardo add 'lib/': https://stackoverflow.com/questions/47119729/rails-loading-custom-class-from-lib-folder-in-controller
    config.autoload_lib(ignore: %w[assets tasks])
  end
end
