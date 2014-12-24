require 'spec_helper'

describe ReviewsController do
  before { Location.stub(:find).and_return(build(:location)) }
  describe 'POST create' do
    context 'with json format' do
      context 'when logged in' do

      end
      context 'when not logged in' do

      end
    end
  end
  describe 'GET index' do
    context 'with json format' do
      let(:valid_params) { { location_id: '123', format: 'json' } }
      context 'when the location has reviews' do
        let(:reviews) { build_list(:review, 2) }
        before { Location.any_instance.stub(:reviews).and_return(reviews) }
        it 'returns the reviews' do
          get :index, valid_params
          response.should be_ok
          response.body.should eq reviews.to_json
        end
      end
      context 'when the location has no reviews' do
        before { Location.any_instance.stub(:reviews).and_return([]) }
        it 'returns 204 no content' do
          get :index, valid_params
          response.status.should eq 204
        end
      end
    end
  end
end

