require 'spec_helper'

describe SessionsController, type: :request do
  describe 'POST /auth/identity/register' do
    let(:name) { 'Evan' }
    let(:password) { 'catluvr123' }
    let(:email) { 'someone@dot.com' }
    context 'with valid parameters' do
      it 'registers a new user' do
        pending 'register is not a valid route'
        expect do
          post '/auth/identity/register', name: name, email: email, password: password, password_confirmation: password
        end.to change { Identity.count }.by(1)
      end
    end
    context 'with invalid parameters' do
      it 'redirects back to the sign-up page with error message' do
        pending 'register is not a valid route'
        expect do
          post '/auth/identity/register', name: name, email: email
        end.to change { Identity.count }.by(0)
      end
    end
  end
end
