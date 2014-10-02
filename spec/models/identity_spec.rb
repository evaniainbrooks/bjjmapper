require 'rails_helper'

describe Identity do
  it 'has a valid factory' do
    build(:identity).should be_valid
  end
  it 'is invalid without a name' do
    build(:identity, name: nil).should_not be_valid  
  end
  it 'is invalid without an email' do
    build(:identity, email: nil).should_not be_valid
  end
  it 'is invalid without a password_digest' do
    build(:identity, password_digest: nil).should_not be_valid
  end
end

