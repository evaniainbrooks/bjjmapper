require 'spec_helper'

describe TeamsController do
  describe 'GET show' do
    let(:team) { create(:team) }
    it 'returns the team' do
      get :show, { id: team.id }
      response.should render_template("teams/show")
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
end

