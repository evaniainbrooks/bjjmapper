require 'spec_helper'

describe LocationsController do
  describe 'GET schedule' do
    context 'with html format' do
      let(:location) { create(:location) }
      it 'returns the location schedule page' do
        get :schedule, format: 'html', id: location
        response.should be_ok
      end
    end
  end
  describe 'GET nearby' do
    let(:location) { build(:location, title: 'self location') }
    before { Location.stub(:find).and_return(location) }
    context 'with json format' do
      context 'when there are locations nearby' do
        let(:other_location) { build(:location, title: 'near you location') }
        before { Location.stub_chain(:near, :limit, :to_a).and_return([other_location]) }
        it 'returns the nearby locations' do
          get :nearby, format: 'json', id: location
          response.body.should_not include(location.title)
          response.body.should include(other_location.title)
        end
      end
      context 'when there are no locations nearby' do
        before { Location.stub_chain(:near, :limit, :to_a).and_return([]) }
        it 'returns 204 no content' do
          get :nearby, format: 'json', id: location
          response.status.should eq 204
        end
      end
    end
  end
  describe 'GET show' do
    context 'with json format' do
      let(:location) { create(:location) }
      it 'returns the location' do
        get :show, format: 'json', id: location
        response.body.should eq location.to_json
      end
    end
    context 'with html format' do
      let(:location) { create(:location) }
      it 'returns the location markup' do
        get :show, id: location
        response.should render_template('locations/show')
      end
    end
  end
  describe 'DELETE destroy' do
    before { @location = create(:location) }
    context 'when not signed in' do
      it 'returns not_authorized'  do
        expect do
          delete :destroy, id: @location, format: 'json'
          response.status.should eq 401
        end.to change { Location.count }.by(0)
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).id } }
      context 'with html format' do
        it 'deletes the record and redirects to root'  do
          expect do
            delete :destroy, {id: @location, format: 'html'}, session_params
            response.should redirect_to(root_path)
          end.to change { Location.count }.by(-1)
        end
      end
      context 'with json format' do
        it 'deletes the record' do
          expect do
            delete :destroy, {id: @location, format: 'json'}, session_params
            response.status.should be 200
          end.to change { Location.count }.by(-1)
        end
      end
    end
  end
  describe 'POST create' do
    let(:create_params) { { :location => { :title => 'New title', :description => 'New description' } } }
    context 'when not signed in' do
      it 'returns not_authorized' do
        expect do
          post :create, create_params.merge({:format => 'json'})
          response.status.should eq 401
        end.to change { Location.count }.by(0)
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      context 'with html format' do
        it 'creates and redirects to a new location in edit mode' do
          expect do
            post :create, create_params.merge({:format => 'html'}), session_params
            response.should redirect_to(location_path(Location.last, edit: 1, create: 1))
          end.to change { Location.count }.by(1)
        end
      end
      context 'with json format' do
        it 'creates and returns a new location' do
          post :create, create_params.merge({:format => 'json'}), session_params
          response.body.should match(create_params[:location][:description])
        end
      end
    end
  end

  describe 'POST update' do
    let(:update_params) { { :location => { :title => 'New title', :description => 'New description' } } }
    let(:original_description) { 'xyz' }
    let(:location) { create(:location, description: original_description) }
    context 'when not signed in' do
      it 'returns not_authorized' do
        post :update, { id: location.id, :format => 'json' }.merge(update_params)
        location.reload.description.should eq original_description
        response.status.should eq 401
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      context 'with json format' do
        it 'updates and returns the location' do
          post :update, { id: location.id, :format => 'json' }.merge(update_params), session_params
          response.body.should match update_params[:location][:description]
        end
      end
      context 'with html format' do
        it 'redirects back to the location' do
          post :update, { id: location.to_param, :format => 'html' }.merge(update_params), session_params
          response.body.should redirect_to(location_path(assigns[:location], edit: 0))
        end
      end
    end
  end

  describe 'GET index' do
    context 'with country and city filter' do
      let(:filter) { { :city => 'New York', :country => 'US' } }
      before do
        create(:location, filter)
        create(:location, city: 'Paris', country: 'FR')
      end
      it 'renders the locations' do
        pending 'geocoding is stubbed, need to move this to an integration test'
        get :index, filter
        assigns[:locations].count.should eq 1
      end
    end
    context 'with country filter' do
      let(:filter) { { :country => 'US' } }
      before do
        create(:location, country: 'US')
        create(:location, country: 'BR')
      end
      it 'renders the directory' do
        pending 'where are the extra locations coming from'
        get :index, filter
        assigns(:locations).count.should eq 1
      end
    end
    context 'without filter' do
      before { create(:location, country: 'BR') }
      it 'renders the directory index' do
        get :index
        assigns(:locations).count.should eq 0
      end
    end
  end
  describe 'GET search' do
    context 'with invalid params' do
      it 'returns bad request' do
        get :search, format: 'json', center: 'ajdfigjfd'
        response.status.should eq 400
      end
    end
    context 'with json format' do
      context 'with existing locations' do
        let(:location) { create(:location, title: 'Wow super location') }
        it 'returns the locations' do
          get :search, center: location.coordinates, distance: 10.0, format: 'json'
          response.body.should include(location.title)
        end
      end
      context 'with no locations' do
        before { Location.destroy_all }
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
          get :search, center: blue_location.coordinates, distance: 10.0, team: [blue_team.id], format: 'json'
          response.body.should include(blue_location.title)
          response.body.should_not include(red_location.title)
        end
      end
      context 'with term filter (query)' do
        context 'with no results' do
          it 'returns 404' do
            pending 'implement me'
            false.should eq true
          end
        end

        context 'with some results' do
          it 'returns the matching locations' do
            pending 'implement me'
            false.should eq true
          end
        end
      end
    end
  end
end
