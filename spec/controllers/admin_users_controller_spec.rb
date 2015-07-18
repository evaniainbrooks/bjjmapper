require 'spec_helper'
require 'shared/tracker_context'

describe Admin::UsersController do
  include_context 'skip tracking'
  describe 'POST merge' do
    let(:location) { create(:location) }
    let(:team) { create(:team) }
    let(:src_user) { create(:user, provider: 'twitter', locations: [location], teams: [team], name: 'SrcUser', description: 'SrcDesc') }
    let(:dst_user) { create(:user, name: 'DstUser', description: nil, internal: true, role: 'super_user') }
    it 'merges the users' do
      post :merge, { id: src_user.id, user: { description: src_user.description } }, { user_id: dst_user.id }
      response.should redirect_to(user_path(dst_user, merge: 1))
    end

    after do
      dst_user.reload
      dst_user.description.should eq src_user.description
      dst_user.locations.first.should eq location
      dst_user.teams.first.should eq team
    end

    after do
      src_user.reload
      src_user.provider.should be_nil
      src_user.locations.should be_empty
      src_user.teams.should be_empty
    end
  end
end

