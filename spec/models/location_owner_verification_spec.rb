require 'spec_helper'

describe LocationOwnerVerification do
  it 'has a factory' do
    build(:location_owner_verification).should be_valid
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
