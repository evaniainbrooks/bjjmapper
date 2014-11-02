require 'spec_helper'

describe Event do
  it 'has a factory' do
    build(:event).should be_valid
  end
  describe 'scopes' do
    before do
      create(:event, starting: 4.hours.ago, ending: 3.hours.ago)
      create(:event, starting: 2.hours.ago, ending: 1.hours.ago)
      create(:event, starting: 1.hours.ago, ending: Time.now)
    end
    describe '#before' do
      let(:subject) { Event.before(2.hours.ago) }
      it 'returns events before the start_time' do
        subject.count.should eq 2
        subject.first.ending.should > 2.hours.ago
      end
    end
    describe '#after' do
      let (:subject) { Event.after(2.hours.ago) }
      it 'returns events after the end_time' do
        subject.count.should eq 2
        subject.first.starting.should < 2.hours.ago
      end
    end
    describe '#between' do
      let (:subject) { Event.between(2.hours.ago, 1.hours.ago) }
      it 'returns events after start_time but before end_time' do
        subject.count.should eq 1
        subject.first.starting.should > 2.hours.ago
        subject.first.starting.should < 1.hours.ago
      end
    end
  end
  describe 'validations' do
    it 'is invalid without a title' do
      build(:event, title: nil).should_not be_valid
    end
    it 'is invalid without a location' do
      build(:event, location: nil).should_not be_valid
    end
  end
  describe '.as_json' do

  end
end
