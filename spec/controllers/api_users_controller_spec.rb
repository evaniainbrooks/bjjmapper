require 'spec_helper'

describe Api::UsersController do
  let(:api_key) { 'some-key-123' }
  let(:user) { create(:user, api_key: api_key) }
  describe 'POST update' do
    let(:update_params) { { :user => { :image => 'new-image.png', :description => 'Buddy Holly' } } }
    context 'with json format' do
      it 'updates and returns the user' do
        post :update, update_params.merge({ :id => user.to_param, :format => 'json', :api_key => user.api_key })
        response.status.should eq 200
        
        assigns[:user].description.should match update_params[:user][:description]
        assigns[:user].image.should match update_params[:user][:image]
      end
    end
  end
end

