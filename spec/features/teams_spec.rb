require 'rails_helper'
require 'shared/locationfetchsvc_context'
require 'shared/tracker_context'
require 'shared/redis_context'

feature "Teams Pages" do
  include_context 'redis'
  include_context 'skip tracking'
  include_context 'locationfetch service'
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  before { allow(FeatureSetting).to receive(:enabled?) { false } }

  scenario "user visits a team detail page" do
    Team.create(name: 'Test Team', description: 'Test Description')
    visit team_path(Team.last.id)
    expect(page).to have_text('Test Team')
  end

  scenario 'user visits a team with locations detail page' do
    pending 'locations are now ajax loaded'

    Team.create(name: 'Test Team', description: 'Test Description')
    Location.create(title: 'Location 123', city: 'Prague', country: 'CZ', team: Team.last)

    visit team_path(Team.last.id)
    expect(page).to have_text('Location 123')
  end
end
