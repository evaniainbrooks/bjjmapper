require 'spec_helper'

describe Api::TeamsController do
  let(:api_key) { 'some-key-123' }
  let(:user) { create(:user, api_key: api_key) }
  describe 'POST update' do
    let(:update_params) { { :team => { image: 'newimg.png', description: 'new desc' } } }
    let(:team) { create(:team, image: 'test123.png', description: 'Old desc') }
    context 'with json format' do
      it 'updates and returns the location' do
        post :update, update_params.merge({ :id => team.to_param, :format => 'json', :api_key => user.api_key })
        response.status.should eq 200

        assigns[:team].description.should match update_params[:team][:description]
        assigns[:team].image.should match update_params[:team][:image]
      end
    end
  end
end

