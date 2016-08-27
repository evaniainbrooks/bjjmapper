require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  abort("ABORTING: specs must be run under test environment")  unless ENV["RAILS_ENV"] == 'test'
  require 'simplecov'

  SimpleCov.minimum_coverage 94
  SimpleCov.maximum_coverage_drop 2
  SimpleCov.start

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'factory_girl'

  Mongoid.load!('./config/mongoid.yml')

  RSpec.configure do |config|
    config.infer_spec_type_from_file_location!
    config.mock_with :rspec do |c|
      c.syntax = [:should, :expect]
    end
    config.include FactoryGirl::Syntax::Methods

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
    config.before do
      Mongoid.truncate!
      FactoryGirl.lint
    end

    config.before(:all) do
      Geocoder.configure(:lookup => :test, :ip_lookup => :test)
      Geocoder::Lookup::Test.set_default_stub(
        [
          {
            'latitude'     => 40.7143528,
            'longitude'    => -74.0059731,
            'address'      => 'New York, NY, USA',
            'city'         => 'New York',
            'state'        => 'New York',
            'state_code'   => 'NY',
            'country'      => 'United States',
            'country_code' => 'US'
          }
        ]
      )

    end
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  I18n.backend.reload!
  Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
end

