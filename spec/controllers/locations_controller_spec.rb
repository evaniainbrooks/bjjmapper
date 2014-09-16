require 'spec_helper'

describe LocationsController do
  describe 'GET show' do
    context 'with json format' do 
      let(:location) { create(:location) } 
      it 'returns the location' do
        get :show, { format: 'json', id: location.id }
        response.body.should eq location.to_json
      end
    end
    context 'with html format' do
      let(:location) { create(:location) } 
      it 'returns the location markup' do
        get :show, { id: location.id }
        response.should render_template("locations/show")
      end
    end
  end

  describe 'GET index' do
    it 'renders the directory' do
      get :index
      response.should render_template("locations/index")
    end
  end
  describe 'GET search' do
    context 'with json format' do
      let(:location) { create(:location) }
      it 'searches the viewport' do
        pending
      end

      context 'with team filter' do
        let(:blue_team) { create(:team, name: 'Blue') }
        let(:red_team) { create(:team, name: 'Red') }
        let(:red_location) { create(:location, team: red_team, title: 'Red location') }
        let(:blue_location) { create(:location, team: blue_team, title: 'Blue location', coordinates: red_location.coordinates) }
        it 'returns specific team locations' do
          get :search, { center: blue_location.coordinates, team: blue_team.id, format: 'json' }
          response.body.should include(blue_location.title)
          response.body.should_not include(red_location.title)
        end
      end
    end
  end
end
