require 'spec_helper'
require 'shared/tracker_context'

describe ReviewsController do
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
    context 'with json format' do
      let(:valid_params) { { format: 'json' } }
      context 'when the location has reviews' do
        context 'with less than 10 reviews' do
          let(:location) { create(:location_with_reviews) }
          it 'returns the reviews' do
            get :index, valid_params.merge({:location_id => location.to_param})
            response.should be_ok
            response.body.should eq location.reviews.to_json
          end
        end
        context 'with more than 10 reviews' do
          let(:location) { create(:location_with_many_reviews) }
          it 'returns the reviews' do
            get :index, valid_params.merge({:location_id => location.to_param})
            response.should be_ok
            response.body.should eq location.reviews.take(10).to_json
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

