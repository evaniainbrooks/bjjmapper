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

  describe '.ig_hashtag' do
    context 'without an explicit value' do
      subject { build(:team, name: 'Instagram Test', ig_hashtag: nil) }
      it 'returns the parameterized name of the team' do
        subject.ig_hashtag.should eq subject.name.parameterize('')
      end
    end
    context 'with an explicit value' do
      subject { build(:team, name: 'Instagram Test', ig_hashtag: 'explicitvalue') }
      it 'returns the explicit value' do
        subject.ig_hashtag.should eq 'explicitvalue'
      end
    end
  end
end
