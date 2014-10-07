require 'spec_helper'
require 'shared/omniauth_context'

describe SessionsController, :type => :request do
  describe 'GET /auth/twitter' do
    context 'with success response' do
      include_context 'omniauth success'
      before { get '/auth/twitter' }
      it 'redirects to success handler' do
        response.should redirect_to("/auth/twitter/callback")
      end
    end
    context 'with invalid credentials' do
      include_context 'omniauth failure'
      before { get '/auth/twitter' }
      it 'redirects to failure handler' do
        pending "investigate why this does not redirect correctly"
        response.should redirect_to(auth_failure_path)
      end
    end
  end
  describe 'GET /auth/facebook' do
    include_context 'omniauth success'
    before { get '/auth/facebook' }
    it 'redirects to success handler' do
      response.should redirect_to("/auth/facebook/callback")
    end
  end
  describe 'GET /auth/google_oauth2' do
    include_context 'omniauth success'
    before { get '/auth/google_oauth2' }
    it 'redirects to success handler' do
      response.should redirect_to("/auth/google_oauth2/callback")
    end
  end
end
