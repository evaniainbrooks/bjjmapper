require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RollFindr
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.timezone_service_host = 'localhost'
    config.timezone_service_port = 443

    config.location_fetch_service_host = 'localhost'
    config.location_fetch_service_port = 443

    config.website_status_service_host = 'localhost'
    config.website_status_service_port = 443

    config.google_maps_api_key = 'AIzaSyDfVeMiIo8lIaMQ_UxahKftMpIutq7QQ4I'
    config.google_maps_endpoint = '//maps.googleapis.com/maps/api/js'

    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.default_options = {from: 'info@bjjmapper.com'}

    config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/
    config.unfingerprint_assets = ["*.svg", "*.eot", "*.woff", "*.ttf", "markers/*"]
    config.lograge.enabled = true

    config.lograge.custom_options = lambda do |event|
      unwanted_keys = %w[format action controller]
      params = event.payload[:params].reject { |key,_| unwanted_keys.include? key }

      {:params => params }
    end
  end
end
