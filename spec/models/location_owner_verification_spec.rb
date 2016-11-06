require 'spec_helper'
require 'shared/locationfetchsvc_context'

describe LocationOwnerVerification do
  include_context 'locationfetch service'
  
  it 'has a factory' do
    build_stubbed(:location_owner_verification).should be_valid
  end
  describe 'validations' do
    it 'is invalid without an email' do
      build_stubbed(:location_owner_verification, email: nil).should_not be_valid
    end
    it 'is invalid without a location' do
      build_stubbed(:location_owner_verification, location: nil).should_not be_valid
    end
    it 'is invalid without a user' do
      build_stubbed(:location_owner_verification, user: nil).should_not be_valid
    end
  end
  describe 'before create' do
    let(:verification) { create(:location_owner_verification) }
    it 'sets the expires at field' do
      verification.expires_at.should be_present
      verification.expires_at.should > Time.now
    end
  end
  describe 'scopes' do
    describe '#with_token' do
      context 'when the context is expired' do
        let(:verification) { create(:location_owner_verification) }
        before { verification.update_attribute(:expires_at, 20.days.ago) }
        it { LocationOwnerVerification.with_token(verification.id).first.should_not be_present }
      end
      context 'when the context is not expired' do
        let(:verification) { create(:location_owner_verification) }
        it { LocationOwnerVerification.with_token(verification.id).first.should be_present }
      end
    end
  end
end
