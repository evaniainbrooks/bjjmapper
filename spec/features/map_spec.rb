require 'rails_helper'

feature "Locations map" do
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  scenario "user visits the main page" do
    visit root_path
    expect(page).to have_selector('.map-canvas')
  end
end
