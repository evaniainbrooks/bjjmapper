require 'spec_helper'
require 'shared/omniauth_context'
require 'shared/tracker_context'

describe SessionsController do
  include_context 'skip tracking'
  describe 'GET new' do
    it 'shows the signin page' do
      get :new
      response.should be_success
    end
  end
  describe 'POST create' do
    let(:anonymous_user) { create(:user, role: 'anonymous') }
    let(:session_params) { { :user_id => anonymous_user.to_param } }
    include_context 'omniauth success'
    before do
      RollFindr::Tracker
        .any_instance
        .should_receive(:alias)
        .with(an_instance_of(String), session_params[:user_id])
    end
    context 'when the user does not exist' do
      it 'creates a user' do
        expect do
          post :create, { provider: omniauth_provider }, session_params
        end.to change{ User.count }.by(1)
      end
      it 'creates a session with the new user' do
        session[:user_id].should be_nil
        post :create, { provider: omniauth_provider }, session_params
        session[:user_id].should eq User.last.to_param
      end
      it 'redirects to the edit profile page with the new user' do
        post :create, { provider: omniauth_provider }, session_params
        response.should redirect_to user_path(User.last.to_param, edit: 1)
      end
    end
    context 'when the user does exist' do
      before do
        @user = create(:user, uid: omniauth_uid, provider: omniauth_provider)
      end
      it 'does not create a user' do
        expect do
          post :create, { provider: omniauth_provider }, session_params
        end.to change{ User.count }.by(0)
      end
      it 'creates a session with the existing user' do
        session[:user_id].should be_nil
        post :create, { provider: omniauth_provider }, session_params
        session[:user_id].should eq @user.to_param
      end
      it 'redirects the user to the root url' do
        post :create, { provider: omniauth_provider }, session_params
        response.should redirect_to root_url
      end
    end
  end

  describe 'GET failure' do
    let(:error_msg) { :invalid_credentials }
    it 'redirects to root with authentication failure message' do
      get :failure, { :message => 'failuremsg123' }
      response.should redirect_to root_url
    end
  end
  describe 'DELETE destroy' do
    before { session[:user_id] = 'loggedin12345' }
    it 'clears the session' do
      delete :destroy
      session[:user_id].should be_nil
    end
    it 'redirects to the home page' do
      delete :destroy
      response.should redirect_to root_url
    end
  end
end

