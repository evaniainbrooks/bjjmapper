require 'rails_helper'
require 'shared/locationfetchsvc_context'
require 'shared/tracker_context'
require 'shared/redis_context'

feature "Directory Segments" do
  include_context 'redis'
  include_context 'skip tracking'
  include_context 'locationfetch service'

  before { allow(FeatureSetting).to receive(:enabled?) { false } }

  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  scenario "user visits the directory index" do
    create(:directory_segment, flag_index_visible: true, name: 'United States')
    create(:team)
    visit directory_index_path
    expect(page).to have_text('United States')
  end

  scenario "user visits a known country" do
    create(:directory_segment, flag_index_visible: true, name: 'United States')
    visit directory_segment_path(country: 'United States')
    expect(page).to have_text('United States')
  end

  scenario "user visits a known city" do
    create(:directory_segment, flag_index_visible: true, name: 'United States')
    create(:directory_segment, name: 'Seattle', parent_segment: DirectorySegment.last)
    visit directory_segment_path(country: 'United States', city: 'Seattle')
    expect(page).to have_text('Seattle')
  end

  scenario "user visits a synthetic directory segment" do
    visit directory_segment_path(country: 'Canada')
    expect(page).to have_text('Canada')
  end
end
