require 'rails_helper'

feature "Locations Pages" do
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  scenario "user visits a location detail page" do
    Location.create(title: 'Test Location', description: 'Test Description', country: 'USA', city: 'Seattle')
    visit location_path(Location.last)
    expect(page).to have_text('Test Location')
  end

  scenario "user visits a location schedule detail page" do
    Location.create(title: 'Test Location', description: 'Test Description', country: 'USA', city: 'Seattle')
    visit schedule_location_path(Location.last)
    expect(page).to have_text('Test Location')
  end
end
