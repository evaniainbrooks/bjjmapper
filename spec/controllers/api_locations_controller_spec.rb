require 'spec_helper'

describe Api::LocationsController do
  let(:api_key) { 'some-key-123' }
  let(:user) { create(:user, api_key: api_key) }
  describe '.current_user' do
    context 'with api_key param' do
      context 'and key is valid' do
        it 'returns the api user' do
          get :index, { api_key: user.api_key, format: 'json' }
          controller.send(:current_user).should eq user
        end
      end
      context 'and key is invalid' do
        it 'returns 403 forbidden' do
          get :index, { api_key: 'bad-key', format: 'json' }, {}
          response.status.should eq 403
        end
      end
    end
  end
  describe 'GET index' do
    let(:locations) { create_list(:location, 10) }
    it 'returns nearby locations' do
      get :index, { api_key: user.api_key, lat: locations.last.lat, lng: locations.last.lng, format: 'json' }
      assigns[:locations].count.should eq locations.count
    end
  end
  describe 'POST create' do
    let(:create_params) do
      { :location => 
        { :city => 'New York',
          :coordinates => [80.0, 80.0],
          :country => 'USA', 
          :title => 'New title', 
          :description => 'New description' 
        } 
      }
    end
    context 'when signed in' do
      context 'when the team is nil' do
        let(:expected_team_name) {'Atos'}
        before do
          Team.stub(:all).and_return([
            build_stubbed(:team, name: expected_team_name),
            build_stubbed(:team, name: 'Other team')
          ])
        end
        let(:team_name_params) { create_params.deep_merge(location: { title: "Academy #{expected_team_name}", team_id: nil}) }
        it 'tries to guess the team from the location title' do
          post :create, team_name_params.merge(api_key: user.api_key, format: 'json')
          assigns[:location].team.name.should eq expected_team_name
        end
      end
      context 'with json format' do
        it 'creates and returns a new location' do
          expect do
            post :create, create_params.merge(api_key: user.api_key, format: 'json')
            assigns[:location].title.should eq create_params[:location][:title]
          end.to change { Location.count }.by(1)
        end
      end
      context 'with invalid params' do
        it 'raises an exception' do
          expect do
            post :create, create_params.tap{|h| h[:location].delete(:title)}.merge(api_key: user.api_key, format: 'json')
          end.to raise_error 
        end
      end
    end
  end
  describe 'POST update' do
    let(:update_params) { { :location => { :title => 'New title', :description => 'New description' } } }
    let(:original_description) { 'xyz' }
    let(:location) { create(:location, description: original_description) }
    context 'when signed in' do
      context 'with json format' do
        it 'updates and returns the location' do
          post :update, { id: location.to_param, :format => 'json', api_key: user.api_key }.merge(update_params)
          assigns[:location].description.should eq update_params[:location][:description]
        end
      end
    end
  end
end
