require 'spec_helper'
require 'shared/tracker_context'

describe LocationStatusesController do
  include_context 'skip tracking'

  STATUSES = {
    'pending' => Location::STATUS_PENDING,
    'reject' => Location::STATUS_REJECTED,
    'verify' => Location::STATUS_VERIFIED
  }.freeze

  STATUSES.keys.each do |status|
    describe "PUT #{status}" do
      subject { build_stubbed(:location, status: 99999) }
      before { Location.stub(:find).and_return(subject) }
      context 'when signed in' do
        before { controller.stub(:current_user).and_return(build(:user, role: 'user')) }
        context 'when permissions allow editing' do
          before { subject.stub(:editable_by?).and_return(true) }
          it 'updates the location status' do
            subject.should_receive(:update_attributes).with(hash_including(:status => STATUSES[status]))
            put status.to_sym, { location_id: '1234', format: 'json' }
            response.status.should eq 202
          end
        end
        context 'when permissions do not allow editing' do
          before { subject.stub(:editable_by?).and_return(false) }
          it 'returns 403 forbidden' do
            subject.should_not_receive(:update_attributes)
            put status.to_sym, { location_id: '1234', format: 'json' }
            response.status.should eq 403
          end
        end
      end
      context 'when not signed in' do
        before { controller.stub(:current_user).and_return(build(:user, role: 'anonymous')) }
        it 'returns 401 not authorized' do
          put status.to_sym, { location_id: '1234', format: 'json' }
          response.status.should eq 401
        end
      end
    end
  end
end