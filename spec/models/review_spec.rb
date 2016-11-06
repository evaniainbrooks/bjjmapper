require 'spec_helper'
require 'shared/locationfetchsvc_context'

describe Review do
  include_context 'locationfetch service'
  it 'has a factory' do
    build_stubbed(:review).should be_valid
  end
  describe 'validations' do
    it 'is invalid without a user' do
      build_stubbed(:review, user: nil).should_not be_valid
    end
    it 'is invalid without a body' do
      build_stubbed(:review, body: nil).should_not be_valid
    end
    it 'is invalid without a rating' do
      build_stubbed(:review, rating: nil).should_not be_valid
    end
    it 'is invalid without an location' do
      build_stubbed(:review, location: nil).should_not be_valid
    end
  end
end
