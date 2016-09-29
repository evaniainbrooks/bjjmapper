require 'spec_helper'

describe Team do
  it 'has a factory' do
    build(:team).should be_present
  end

  it 'has a decorator' do
    Team.new.decorate.should be_decorated
  end

  describe '.editable_by?' do
    context 'when the user is a super user' do
      subject { build(:team) }
      let(:editor) { build(:user, role: 'super_user') }
      it { subject.editable_by?(editor).should eq true }
    end
    context 'when the user is not a super user' do
      let(:editor) { build(:user, role: 'user') }
      context 'with the locked flag' do
        subject { build(:team, locked: true) }
        it { subject.editable_by?(editor).should eq false }
      end
      context 'without the locked flag' do
        subject { build(:team, locked: false) }
        it { subject.editable_by?(editor).should eq true }
      end
    end
  end

  describe '.destroyable_by?' do
    context 'when it is editable' do
      subject { build(:team, locked: false) }
      let(:editor) { build(:user, role: 'super_user') }
      context 'with locations' do
        before { subject.locations << build(:location) }
        it { subject.destroyable_by?(editor).should eq false }
      end
      context 'without locations' do
        it { subject.destroyable_by?(editor).should eq true }
      end
    end
    context 'when it is not editable' do
      subject { build(:team, locked: true) }
      let(:editor) { build(:user, role: 'user') }
      it { subject.destroyable_by?(editor).should eq false }
    end
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
