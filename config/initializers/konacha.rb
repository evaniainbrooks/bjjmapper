# config/initializers/konacha.rb
if defined?(Konacha)
  require 'capybara/poltergeist'
  Capybara.register_driver :slow_poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, :timeout => 180)
  end
  Konacha.configure do |config|
    config.driver = :slow_poltergeist
    config.javascripts = %w(chai chai-backbone jquery chai-jquery chai-changes sinon konacha konacha/iframe)
    config.spec_dir = 'spec/javascripts'
    config.stylesheets = %w{application}
  end
end
