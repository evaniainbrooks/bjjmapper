require 'spec_helper'

describe Organization do
  it 'has a factory' do
    build_stubbed(:organization).should be_valid
  end

  describe 'validations' do
    it 'is invalid without a name' do
      build_stubbed(:organization, name: nil).should_not be_valid
    end
    it 'is invalid without an abbreviation' do
      build_stubbed(:organization, abbreviation: nil).should_not be_valid
    end
    it 'is invalid without a website' do
      build_stubbed(:organization, website: nil).should_not be_valid
    end
  end
end
