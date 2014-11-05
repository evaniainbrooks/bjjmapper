require 'spec_helper'

describe Team do
  it 'has a factory' do
    build(:team).should be_present
  end
  
  it 'has a decorator' do
    Team.new.decorate.should be_decorated
  end
  
  describe '.as_json' do
    it 'returns the object as json' do
      json = build(:team).as_json({})
      [:id, :parent_team_id].each {|x| json.should have_key(x) }
    end
  end
  
  describe 'validations' do
    it 'is invalid without a name' do
      build(:team, name: nil).should_not be_valid
    end
  end
end
