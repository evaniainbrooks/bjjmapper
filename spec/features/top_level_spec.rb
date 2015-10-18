require 'rails_helper'

feature "Top Level Pages" do
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  scenario "user visits the main page" do
    visit root_path
    expect(page).to have_selector('.homepage')
  end
  scenario "user visits the map" do
    visit map_path
    expect(page).to have_selector('.map-canvas')
  end
  scenario "user visits the directory" do
    create(:directory_segment)
    visit directory_index_path
    expect(page).to have_selector('.directory')
  end
  scenario "user visits the meta page" do
    visit meta_path
    expect(page).to have_selector('.meta')
  end
end
