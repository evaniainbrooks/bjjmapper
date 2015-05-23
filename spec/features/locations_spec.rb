require 'rails_helper'

feature "Locations Pages" do
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  scenario "user visits a team detail page" do
    Location.create(title: 'Test Location', description: 'Test Description')
    visit location_path(Location.last.id)
    expect(page).to have_text('Test Location')
  end
end
