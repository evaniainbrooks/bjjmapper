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

  describe 'DELETE destroy' do
    let(:location) { create(:location) }
    
    context 'with html format' do
      it 'deletes the record and redirects to root'  do
        location
        expect {
          delete :destroy, { id: location.id, format: 'html' }
          response.should redirect_to(root_path)
        }.to change { Location.count }.by(-1)
      end
    end
    context 'with json format' do
      it 'deletes the record' do
        location
        expect {
          delete :destroy, { id: location.id, format: 'json' }
          response.status.should be 200
        }.to change { Location.count }.by(-1)
      end
    end
  end
  describe 'POST instructors' do
    let(:instructor) { create(:user) }
    let(:location) { create(:location) }
    let(:valid_params) { { :id => location.id, :instructor_id => instructor.id } }
    context 'with html format' do
      it 'adds the instructor to the location and redirects back' do
        expect {
          post :instructors, valid_params
          response.should redirect_to(location_path(location, edit: 0))
        }.to change { Location.find(location.id).instructors.count }.by(1)
      end
    end
    context 'with json format' do
      it 'adds the instructor to the location' do
        expect {
          post :instructors, valid_params.merge(:format => 'json')
        }.to change { Location.find(location.id).instructors.count }.by(1)
      end
    end
  end
  describe 'POST create' do
    let(:create_params) { { :location => { :title => 'New title', :description => 'New description' }}}
    context 'with html format' do
      it 'creates and redirects to a new location in edit mode' do
        expect {
          post :create, create_params.merge({:format => 'html'})
          response.should redirect_to(location_path(Location.first, edit: 1))
        }.to change { Location.count }.by(1)
      end
    end
    context 'with json format' do
      it 'creates and returns a new location' do
        post :create, create_params.merge({:format => 'json'})
        response.body.should match(create_params[:location][:description])
      end
    end
  end

  describe 'POST update' do
    let(:update_params) { { :location => { :title => 'New title', :description => 'New description' }}}
    context 'with json format' do
      let(:location) { create(:location, description: 'xyz') }
      it 'updates and returns the location' do
        post :update, { id: location.id, :format => 'json' }.merge(update_params)
        response.body.should match update_params[:location][:description]
      end
    end
    context 'with html format' do
      let(:location) { create(:location, description: 'xyz') }
      it 'redirects back to the location' do
        post :update, { id: location.id, :format => 'html' }.merge(update_params)
        response.body.should redirect_to(location_path(location, edit: 0)) 
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
    context 'with invalid params' do
      it 'returns bad request' do
        get :search, { format: 'json', center: 'ajdfigjfd' }
        response.status.should eq 400
      end
    end
    context 'with json format' do
      context 'with existing locations' do
        let(:location) { create(:location, title: 'Wow super location') }
        it 'returns the locations' do
          get :search, { center: location.coordinates, distance: 10.0, format: 'json' }
          response.body.should include(location.title)
        end
      end
      context 'with no locations' do
        it 'returns no content' do
          get :search, { center: [80.0, 80.0], format: 'json' }
          response.status.should eq 204
        end
      end
      context 'with team filter' do
        let(:blue_team) { create(:team, name: 'Blue') }
        let(:red_team) { create(:team, name: 'Red') }
        let(:red_location) { create(:location, team: red_team, title: 'Red location') }
        let(:blue_location) { create(:location, team: blue_team, title: 'Blue location', coordinates: red_location.coordinates) }
        it 'returns specific team locations' do
          get :search, { center: blue_location.coordinates, distance: 10.0, team: [blue_team.id], format: 'json' }
          response.body.should include(blue_location.title)
          response.body.should_not include(red_location.title)
        end
      end
    end
  end
end
