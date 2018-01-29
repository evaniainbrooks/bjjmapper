require 'rails_helper'
require 'shared/locationfetchsvc_context'
require 'shared/tracker_context'
require 'shared/redis_context'


feature "Locations Pages" do
  include_context 'redis'
  include_context 'skip tracking'
  include_context 'locationfetch service'
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  before { allow(FeatureSetting).to receive(:enabled?) { false } }

  scenario "user visits a location detail page" do
    Location.create(title: 'Test Location', description: 'Test Description', country: 'USA', city: 'Seattle', coordinates: [80.0, 80.0])
    Event.create(title: 'Test Event', location: Location.last, modifier: User.last, starting: Time.now, ending: Time.now + 1.day)
    visit location_path(Location.last)
    expect(page).to have_text('Test Location')
  end

  scenario "user visits a location schedule detail page" do
    Location.create(title: 'Test Location', description: 'Test Description', country: 'USA', city: 'Seattle', coordinates: [80.0, 80.0])
    visit schedule_location_path(Location.last)
    expect(page).to have_text('Test Location')
  end
end
