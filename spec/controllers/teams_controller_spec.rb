require 'spec_helper'

describe TeamsController do
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
end

