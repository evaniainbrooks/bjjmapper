require 'spec_helper'
require 'shared/tracker_context'

describe LocationReviewsController do
  include_context 'skip tracking'
  describe 'POST create' do
    context 'with json format' do
      let(:location) { create(:location) }
      let(:review_params) { { rating: 1, body: 'test' } }
      let(:valid_params) { { format: 'json', location_id: location.to_param, review: review_params } }
      context 'when logged in' do
        let(:user) { create(:user) }
        let(:session_params) { { user_id: user.id } }
        it 'creates a new review' do
          expect do
            post :create, valid_params, session_params
            response.should be_ok
          end.to change { Review.count }.by(1)
        end
      end
      context 'when not logged in' do
        it 'returns not_authorized' do
          expect do
            post :create, valid_params, {}
            response.status.should eq 401
          end.to change { Review.count }.by(0)
        end
      end
    end
  end
  describe 'GET index' do
    before { ::RollFindr::LocationFetchService.stub(:reviews).and_return({reviews: []}) }
    context 'with json format' do
      let(:valid_params) { { format: 'json' } }
      context 'when the location has reviews' do
        context 'with reviews' do
          let(:location) { create(:location_with_reviews) }
          it 'returns the reviews' do
            get :index, valid_params.merge({:location_id => location.to_param})
            response.should be_ok
            assigns[:reviews].count.should eq location.reviews.count
          end
        end
        context 'with more than :count reviews' do
          let(:location) { create(:location_with_many_reviews) }
          let(:expected_count) { 5 }
          it 'returns only :count reviews' do
            get :index, valid_params.merge({:count => expected_count, :location_id => location.to_param})
            response.should be_ok
            assigns[:reviews].count.should eq expected_count
          end
        end
      end
      context 'when the location has no reviews' do
        let(:location) { create(:location) }
        it 'returns 204 no content' do
          get :index, valid_params.merge({:location_id => location.to_param})
          response.status.should eq 204
        end
      end
    end
  end
end

