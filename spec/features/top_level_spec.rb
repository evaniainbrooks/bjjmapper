require 'rails_helper'
require 'shared/locationfetchsvc_context'
require 'shared/tracker_context'

feature "Top Level Pages" do
  include_context 'skip tracking'
  include_context 'locationfetch service'
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  scenario "user visits the main page" do
    create(:directory_segment)
    visit root_path
    expect(page).to have_selector('.homepage')
  end
  scenario "user visits the map" do
    visit map_path
    expect(page).to have_selector('.map-canvas')
    expect(page).to have_selector('[data-show-map]')
  end
  scenario "user visits the directory" do
    create(:directory_segment)
    create(:team)
    visit directory_index_path
    expect(page).to have_selector('.directory')
    expect(page).not_to have_selector('[data-show-map]')
  end
  scenario "user visits the meta page" do
    visit meta_path
    expect(page).to have_selector('.meta')
  end
end
