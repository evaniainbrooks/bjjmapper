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

  scenario 'user visits his own profile' do
    User.create(name: 'Evan', role: 'user')
    visit user_path(User.last)
    expect(page).to have_text('Evan')
  end

  scenario 'user visits the users index' do
    pending 'in progress'
    User.create(name: 'Evan', role: 'user', belt_rank: 'black')
    visit users_path
    expect(page).to have_text('Evan')
  end
end
