require 'rails_helper'

feature "Locations map" do
  scenario "user visits the main page" do
    visit root_path
    expect(page).to have_selector('.map-canvas')
  end
end
