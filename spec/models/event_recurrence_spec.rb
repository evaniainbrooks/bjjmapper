require 'spec_helper'

describe EventRecurrence do
  it 'has a factory' do
    build(:event_recurrence).should be_valid
  end

  describe 'validations' do
    it 'is invalid without a recurrence_rule' do
      build(:event_recurrence, recurrence_rule: nil).should_not be_valid
    end
  end

  describe '.rule' do
    subject { build(:event_recurrence) }
    let(:recurrence_rule) { IceCube::Rule.daily(2).count(3) }
    it 'serializes the ice_cube rule as yaml' do
      subject.rule = recurrence_rule
      subject.recurrence_rule.should eq recurrence_rule.to_yaml
    end
  end
end
