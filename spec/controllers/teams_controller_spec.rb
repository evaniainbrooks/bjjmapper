require 'spec_helper'
require 'shared/tracker_context'

describe TeamsController do
  include_context 'skip tracking'
  describe 'GET new' do
    context 'when not signed in' do
      it 'redirects to the login page' do
        get :new
        response.should redirect_to(signin_path)
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      it 'shows the create team page' do
        get :new, {}, session_params
        response.should be_ok
      end
    end
  end

  describe 'GET create' do
    let(:create_params) { { :team => { :name => 'New title', :description => 'New description' } } }
    context 'when not signed in' do
      it 'returns not_authorized' do
        expect do
          post :create, create_params.merge({:format => 'json'})
          response.status.should eq 401
        end.to change { Team.count }.by(0)
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      context 'with html format' do
        it 'creates and redirects to a new team in edit mode' do
          expect do
            post :create, create_params.merge({:format => 'html'}), session_params
            response.should redirect_to(team_path(Team.last, edit: 1, create: 1))
          end.to change { Team.count }.by(1)
        end
      end
      context 'with json format' do
        it 'creates and returns a new team' do
          post :create, create_params.merge({:format => 'json'}), session_params
          response.body.should match(create_params[:team][:description])
        end
      end
    end
  end
  describe 'GET show' do
    let(:team) { create(:team) }
    it 'returns the team' do
      get :show, { id: team.id }
      response.should render_template('teams/show')
    end
  end
  describe 'GET index' do
    context 'with json format' do
      let(:teams) { [] }
      before do
        3.times { |id| teams << create(:team, name: "Team#{id}") }
      end
      it 'returns the teams' do
        get :index, { format: 'json' }
        teams.each { |t| response.body.should match(t.name) }
      end
    end
  end
  describe 'POST update' do
    let(:update_params) { { :team => { :name => 'New name', :description => 'New description' } } }
    let(:original_description) { 'xyz' }
    let(:team) { create(:team, description: original_description) }
    context 'when not signed in' do
      it 'returns not_authorized' do
        post :update, { id: team.to_param, :format => 'json' }.merge(update_params)
        team.reload.description.should eq original_description
        response.status.should eq 401
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      context 'with json format' do
        it 'updates and returns the location' do
          post :update, { id: team.to_param, :format => 'json' }.merge(update_params), session_params
          response.body.should match update_params[:team][:description]
        end
      end
      context 'with html format' do
        it 'redirects back to the location' do
          post :update, { id: team.to_param, :format => 'html' }.merge(update_params), session_params
          response.body.should redirect_to(team_path(assigns[:team], edit: 0))
        end
      end
    end
  end
  describe 'POST remove_image' do
    let(:team) { create(:team, image: 'xyz', image_large: 'abc') }
    context 'when not signed in' do
      it 'returns not_authorized' do
        post :remove_image, { id: team.to_param, :format => 'json' }
        response.status.should eq 401
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      context 'with json format' do
        it 'clears the images and returns the location' do
          post :remove_image, { id: team.to_param, :format => 'json' }, session_params
          assigns[:team].image.should eq nil
          assigns[:team].image_large.should eq nil
        end
      end
    end
  end
end

