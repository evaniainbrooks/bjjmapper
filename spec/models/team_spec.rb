require 'spec_helper'

describe Team do
  it 'has a factory' do
    build(:team).should be_present
  end
  
  it 'has a decorator' do
    Team.new.decorate.should be_decorated
  end
end
