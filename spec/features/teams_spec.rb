require 'rails_helper'

feature "Teams Pages" do
  background do
    Capybara.current_session.driver.header('Accept-Language', 'en')
    Capybara.current_session.driver.header('User-Agent', 'TestUserAgent')
  end

  scenario "user visits a team detail page" do
    Team.create(name: 'Test Team', description: 'Test Description')
    visit team_path(Team.last.id)
    expect(page).to have_text('Test Team')
  end
end
