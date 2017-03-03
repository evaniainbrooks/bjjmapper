require 'rails_helper'

describe Identity do
  it 'has a valid factory' do
    build_stubbed(:identity).should be_valid
  end
  it 'is invalid without a name' do
    build_stubbed(:identity, name: nil).should_not be_valid
  end
  it 'is invalid without an email' do
    build_stubbed(:identity, email: nil).should_not be_valid
  end
  it 'is invalid without a password_digest' do
    build_stubbed(:identity, password_digest: nil).should_not be_valid
  end
end

