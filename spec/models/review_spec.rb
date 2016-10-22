require 'spec_helper'

describe Review do
  it 'has a factory' do
    build(:review).should be_valid
  end
  describe 'validations' do
    it 'is invalid without a user' do
      build(:review, user: nil).should_not be_valid
    end
    it 'is invalid without a body' do
      build(:review, body: nil).should_not be_valid
    end
    it 'is invalid without a rating' do
      build(:review, rating: nil).should_not be_valid
    end
    it 'is invalid without an location' do
      build(:review, location: nil).should_not be_valid
    end
  end
end
