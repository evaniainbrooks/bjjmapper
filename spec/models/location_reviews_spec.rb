require 'spec_helper'

describe LocationReviews do
  subject { LocationReviews.new('location-id') }
  let(:expected_rating) { 5.0 }
  let(:service_response) { { reviews: [{body: 'test'}], rating: expected_rating } }
  before { Review.stub(:where).and_return([build(:review, location: nil, user: nil)]) }
  before { ::RollFindr::LocationFetchService.stub(:reviews).and_return(service_response) }
  describe '.items' do
    it 'returns an array of local and remote (locationfetchsvc) reviews for the location' do
      subject.items.count.should eq 2
    end
  end
  describe '.rating' do
    it 'returns the rating from the locationfetchsvc' do
      subject.rating.should eq expected_rating
    end
  end
end
