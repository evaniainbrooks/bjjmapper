require 'spec_helper'
require 'shared/tracker_context'

describe UserReviewsController do
  include_context 'skip tracking'
  describe 'GET index' do
    context 'with json format' do
      let(:user) { create(:user) }
      let(:location) { create(:location) }
      before { create(:review, user: user, location: location) }
      it 'returns the recent reviews' do
        get :index, user_id: user.to_param, format: 'json', count: 1
        response.should be_success
        assigns[:reviews].collect(&:to_param).should include(user.reload.reviews.first.to_param)
      end
    end
    context 'with legacy bsonid' do
      let(:user) { create(:user) }
      it 'redirects to slug' do
        get :index, user_id: user.id, format: 'json', count: 1
        response.should redirect_to(user_reviews_path(user))
      end
    end
  end
end
