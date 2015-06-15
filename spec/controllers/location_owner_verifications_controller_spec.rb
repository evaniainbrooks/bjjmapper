require 'spec_helper'
require 'shared/tracker_context'

describe LocationOwnerVerificationsController do
  include_context 'skip tracking'
  describe 'GET verify' do
    context 'when the solicitation is expired' do
      let(:verification) { create(:location_owner_verification) }
      before do
        verification.update_attribute(:expires_at, 20.days.ago)
      end
      it 'returns 404 not found' do
        get :verify, { id: verification.id }
        response.status.should eq 404
      end
    end

    context 'when the solicitation is valid' do
      let(:email) { 'new_email_addr' }
      let(:verification) { create(:location_owner_verification, email: email) }
      it 'updates the location owner and email' do
        verification.location.owner.should eq nil
        get :verify, { id: verification.id }

        response.should redirect_to(location_path(verification.location, verified: 1))
        verification.reload.location.owner.should eq verification.user
        verification.location.email.should eq email
      end
    end
  end
  describe 'POST create' do
    let(:location) { create(:location) }
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).id } }
      it 'creates a new verification context' do
        expect do
          post :create, { location_id: location.id, format: 'json' }, session_params
          assigns[:verification].location.should eq location
          assigns[:verification].user.id.should eq session_params[:user_id]
        end.to change { LocationOwnerVerification.count }.by(1)
      end
    end
    context 'when not signed in' do
      let (:empty_session) { {} }
      it 'returns not_authorized' do
        expect do
          post :create, { location_id: location.id, format: 'json' }, empty_session
          response.status.should eq 401
        end.to change { LocationOwnerVerification.count }.by(0)
      end
    end
  end
end

