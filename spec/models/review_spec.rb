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
  describe '.as_json' do
    it 'returns the object as json' do
      json = build(:review).as_json({})
      [:user_id, :user_name, :body, :rating, :created_at].each {|x| json.should have_key(x) }
    end
  end
end
