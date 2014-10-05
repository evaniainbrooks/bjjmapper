require 'spec_helper'
require 'shared/omniauth_context'

describe SessionsController do
  include_context 'omniauth'
  
  describe "GET new" do
    it "shows the signin page" do
      get :new
      response.should be_success
    end
  end
  describe "POST create" do
    context 'when the user does not exist' do
      it "creates a user" do
        expect {
          post :create, provider: omniauth_provider
        }.to change{ User.count }.by(1)
      end
      it 'creates a session with the new user' do
        session[:user_id].should be_nil
        post :create, provider: omniauth_provider
        session[:user_id].should eq User.last.id
      end
    end
    context 'when the user does exist' do
      before { @user = create(:user, uid: omniauth_uid, provider: omniauth_provider) }
      it 'does not create a user' do
        expect {
          post :create, provider: omniauth_provider
        }.to change{ User.count }.by(0)
      end
      it 'creates a session with the existing user' do
        session[:user_id].should be_nil
        post :create, provider: omniauth_provider
        session[:user_id].should eq @user.id
      end
    end
    it "redirects the user to the root url" do
      post :create, provider: omniauth_provider
      response.should redirect_to root_url
    end
  end
  describe "DELETE destroy" do
    before do
      post :create, provider: omniauth_provider
    end
    it "should clear the session" do
      session[:user_id].should_not be_nil
      delete :destroy
      session[:user_id].should be_nil
    end
    it "should redirect to the home page" do
      delete :destroy
      response.should redirect_to root_url
    end
  end
end

