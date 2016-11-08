require 'rails_helper'
require 'shared/locationfetchsvc_context'
require 'shared/tracker_context'

feature 'Event Pages' do
  include_context 'skip tracking'
  include_context 'locationfetch service'

  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  before do
    create(:location)
    create(:user, role: 'user')
  end

  scenario 'user visits a regular class event' do
    event = create(:event, location: Location.last, modifier: User.last, event_type: Event::EVENT_TYPE_CLASS)
    visit location_event_path(Location.last, event)
    expect(page).to have_selector('.show-event')
  end

  scenario 'user visits a tournament event' do
    event = create(:event, location: Location.last, modifier: User.last, event_type: Event::EVENT_TYPE_TOURNAMENT)
    visit location_event_path(Location.last, event)
    expect(page).to have_selector('.show-event')
  end

  scenario 'user visits a seminar event' do
    event = create(:event, location: Location.last, modifier: User.last, event_type: Event::EVENT_TYPE_SEMINAR)
    visit location_event_path(Location.last, event)
    expect(page).to have_selector('.show-event')
  end
end
