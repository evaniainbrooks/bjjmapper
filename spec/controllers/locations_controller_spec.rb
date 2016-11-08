require 'spec_helper'
require 'shared/tracker_context'
require 'shared/timezonesvc_context'

describe LocationsController do
  include_context 'skip tracking'
  include_context 'timezone service'
  
  describe 'POST unlock' do
    subject { build(:location, team: nil) }
    before { Location.stub_chain(:verified, :academies, :find).and_return(subject) }
    context 'when signed in' do
      before { controller.stub(:current_user).and_return(build(:user, role: 'user')) }
      context 'when permissions allow editing' do
        before { subject.stub(:editable_by?).and_return(true) }
        it 'clears the owner field' do
          subject.should_receive(:update_attribute).with(:owner_id, nil)
          post :unlock, { id: '1234', format: 'json' }
          response.status.should eq 200
        end
      end
      context 'when permissions do not allow editing' do
        before { subject.stub(:editable_by?).and_return(false) }
        it 'returns 403 forbidden' do
          subject.should_not_receive(:update_attribute).with(:owner_id, nil)
          post :unlock, { id: '1234', format: 'json' }
          response.status.should eq 403
        end
      end
    end
    context 'when not signed in' do
      before { controller.stub(:current_user).and_return(build(:user, role: 'anonymous')) }
      it 'returns 401 not authorized' do
        post :unlock, { id: '1234', format: 'json' }
        response.status.should eq 401
      end
    end
  end
  describe 'POST close' do
    subject { build(:location, team: nil) }
    before { Location.stub_chain(:academies, :find).and_return(subject) }
    context 'when signed in' do
      before { controller.stub(:current_user).and_return(build(:user, role: 'user')) }
      context 'when permissions allow editing' do
        before { subject.stub(:editable_by?).and_return(true) }
        it 'sets the closed flag' do
          subject.should_receive(:update_attribute).with(:flag_closed, true)
          post :close, { id: '1234', format: 'json' }
          response.status.should eq 200
        end
      end
      context 'when permissions do not allow editing' do
        before { subject.stub(:editable_by?).and_return(false) }
        it 'returns 403 forbidden' do
          subject.should_not_receive(:update_attribute).with(:flag_closed, true)
          post :close, { id: '1234', format: 'json' }
          response.status.should eq 403
        end
      end
    end
    context 'when not signed in' do
      before { controller.stub(:current_user).and_return(build(:user, role: 'anonymous')) }
      it 'returns 401 not authorized' do
        post :close, { id: '1234', format: 'json' }
        response.status.should eq 401
      end
    end
  end
  describe 'GET recent' do
    context 'with json format' do
      subject { build_list(:location, 2) }
      before { Location.stub_chain(:verified, :desc, :limit).and_return(subject) }
      it 'returns the recent locations' do
        get :recent, format: 'json', count: 2
        response.should be_success
      end
    end
  end
  describe 'GET schedule' do
    context 'with html format' do
      let(:location) { create(:location) }
      it 'returns the location schedule page' do
        get :schedule, format: 'html', id: location
        response.should be_ok
      end
    end
    context 'when the location is an event venue' do
      let(:event_venue) { create(:event_venue) }
      it 'returns the location schedule page' do
        get :schedule, format: 'html', id: event_venue
        response.should be_ok
      end
    end
  end
  describe 'GET nearby' do
    let(:location) { create(:location, title: 'self location') }
    context 'with json format' do
      context 'with missing lat, lng params' do
        it 'returns 400 bad request' do
          get :nearby, format: 'json'
          response.status.should eq 400
        end
      end
      context 'when there are locations nearby' do
        let(:other_location) { build(:location, title: 'near you location') }
        before { Location.stub_chain(:near, :where, :verified, :limit, :to_a).and_return([location, other_location]) }
        context 'with reject parameter' do
          it 'returns the nearby locations without the rejected location' do
            get :nearby, format: 'json', reject: location.to_param, lat: 80.0, lng: 80.0
            assigns[:locations].collect(&:title).tap do |locations|
              locations.should_not include(location.title)
              locations.should include(other_location.title)
            end
          end
        end
        context 'without reject parameter' do
          it 'returns the nearby locations' do
            get :nearby, format: 'json', lat: 80.0, lng: 80.0

            assigns[:locations].first.distance.should_not be_nil
            assigns[:locations].collect(&:title).tap do |locations|
              locations.should include(location.title)
              locations.should include(other_location.title)
            end
          end
        end
      end
      context 'when there are no locations nearby' do
        before { Location.stub_chain(:near, :where, :verified, :limit, :to_a).and_return([]) }
        it 'returns 204 no content' do
          get :nearby, format: 'json', lat: 80.0, lng: 80.0
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
        assigns[:location].title.should eq location.title
      end
    end
    context 'with html format' do
      let(:location) { create(:location) }
      it 'returns the location markup' do
        get :show, id: location
        response.should render_template('locations/show')
      end
    end
    context 'when the location does not exist' do
      before { Location.stub_chain(:verified, :academies, :find).and_return(nil) }
      it 'returns 404 not found' do
        get :show, id: 'bogus'
        response.status.should eq 404
      end
    end
    context 'when the location is an event venue' do
      context 'and not super_user?' do
        let(:location) { create(:location, loctype: Location::LOCATION_TYPE_EVENT_VENUE) }
        it 'returns 404 not found' do
          get :show, id: location
          response.status.should eq 404
        end
      end
      context 'and super_user?' do
        let(:location) { create(:location, loctype: Location::LOCATION_TYPE_EVENT_VENUE) }
        let(:session_params) { { user_id: create(:user, role: 'super_user').id } }
        it 'returns the location' do
          get :show, {id: location}, session_params
          response.should render_template('locations/show')
        end
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
  describe 'GET wizard' do
    context 'when not signed in' do
      it 'redirects to the login page' do
        get :wizard
        response.should redirect_to(signin_path)
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      it 'shows the wizard' do
        get :wizard, {}, session_params
        response.should be_ok
      end
    end
  end
  describe 'POST create' do
    let(:create_params) { { :location => { :city => 'New York', :country => 'USA', :title => 'New title', :description => 'New description' } } }
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
          assigns[:location].title.should eq create_params[:location][:title]
        end
      end
    end
  end
  describe 'POST favorite' do
    let(:current_user) { create(:user) }
    let(:session_params) { { user_id: current_user.id } }
    let(:location) { create(:location) }
    context 'with delete param' do
      before do
        current_user.favorite_locations << location
      end
      it 'deletes the location from the current_user favorites list' do
        expect do
          post :favorite, { delete: 1, id: location.to_param, format: 'json' }, session_params
          current_user.reload.favorite_locations.should_not include(location)
        end.to change { current_user.favorite_locations.count }.by(-1)
      end
    end
    context 'without delete param' do
      it 'adds the location to the current_user favorites list' do
        expect do
          post :favorite, { delete: 0, id: location.to_param, format: 'json' }, session_params
          current_user.reload.favorite_locations.should include(location)
        end.to change { current_user.favorite_locations.count }.by(1)
      end
    end
  end
  describe 'POST update' do
    let(:update_params) { { :location => { :title => 'New title', :description => 'New description' } } }
    let(:original_description) { 'xyz' }
    let(:location) { create(:location, description: original_description) }
    context 'when not signed in' do
      it 'returns not_authorized' do
        post :update, { id: location.to_param, :format => 'json' }.merge(update_params)
        location.reload.description.should eq original_description
        response.status.should eq 401
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      context 'with json format' do
        it 'updates and returns the location' do
          post :update, { id: location.to_param, :format => 'json' }.merge(update_params), session_params
          assigns[:location].description.should eq update_params[:location][:description]
        end
      end
      context 'with html format' do
        it 'redirects back to the location' do
          post :update, { id: location.to_param, :format => 'html' }.merge(update_params), session_params
          response.body.should redirect_to(location_path(assigns[:location], success: 1, edit: 0))
        end
      end
    end
  end
  describe 'POST move' do
    let(:move_params) { { :lat => 90.0, :lng => 90.0 } }
    let(:location) { create(:location) }
    let(:original_coords) { location.coordinates }
    let(:common_params) { { id: location.to_param, format: 'json' } }
    context 'when not signed in' do
      it 'returns not_authorized' do
        post :move, common_params.merge(move_params)
        location.reload.coordinates.should eq original_coords
        response.status.should eq 401
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      context 'with json format' do
        it 'moves and returns the location' do
          post :move, common_params.merge(move_params), session_params
          assigns[:location].to_coordinates[0].should match move_params[:lat]
          assigns[:location].to_coordinates[1].should match move_params[:lng]
        end
      end
      context 'with missing lat, lng params' do
        it 'returns 400 bad request' do
          post :move, common_params, session_params
          response.status.should eq 400
        end
      end
    end
  end
end
