require 'spec_helper'

describe TeamsController do
  describe 'GET show' do
    let(:team) { create(:team) }
    it 'returns the team' do
      get :show, { id: team.id }
      response.should render_template("teams/show")
    end
  end
end

