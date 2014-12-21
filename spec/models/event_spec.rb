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
    describe '#before_time' do
      let(:subject) { Event.before_time(2.hours.ago) }
      it 'returns events before the start_time' do
        subject.count.should eq 2
        subject.first.ending.should > 2.hours.ago
      end
    end
    describe '#after_time' do
      let (:subject) { Event.after_time(2.hours.ago) }
      it 'returns events after the end_time' do
        subject.count.should eq 2
        subject.first.starting.should < 2.hours.ago
      end
    end
    describe '#between_time' do
      let (:subject) { Event.between_time(2.hours.ago, 1.hours.ago) }
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
    it 'is invalid without a modifier' do
      build(:event, modifier: nil).should_not be_valid
    end
    it 'is valid without an instructor' do
      build(:event, instructor: nil).should be_valid
    end
    it 'is invalid without a start time' do
      build(:event, starting: nil).should_not be_valid
    end
    it 'is invalid without an end time' do
      build(:event, ending: nil).should_not be_valid
    end
    it 'is invalid if end time is before start time' do
      build(:event, starting: 1.hour.ago, ending: 2.hours.ago).should_not be_valid
    end
  end
  describe 'before_save callback' do
    describe '.create_schedule' do
      context 'when .event_recurrence is NONE' do
        subject { build(:event, event_recurrence: Event::RECURRENCE_NONE) }
        before { subject.save }
        it 'does not create a schedule' do
          subject.read_attribute(:schedule).should be_nil
        end
      end
      context 'when .event_recurrence is DAILY' do
        subject { build(:event, event_recurrence: Event::RECURRENCE_DAILY) }
        before { subject.save }
        it 'adds a daily recurrence rule to the schedule' do
          subject.schedule.recurrence_rules.first.should be_a(IceCube::DailyRule)
        end
      end
      context 'when .event_recurrence is WEEKLY' do
        let(:recurrence_days) { ["0", "1"] }
        subject { build(:event, event_recurrence: Event::RECURRENCE_WEEKLY, weekly_recurrence_days: recurrence_days) }
        before { subject.save }
        it 'adds a weekly recurrnce rule to the schedule' do
          subject.schedule.recurrence_rules.first.should be_a(IceCube::WeeklyRule)
          subject.schedule.recurrence_rules.first.should eq IceCube::Rule.weekly(1).day(*recurrence_days.map(&:to_i))
        end
      end
    end
    describe '.serialize_schedule' do
      context 'with a schedule' do
        subject { build(:event, event_recurrence: Event::RECURRENCE_DAILY) }
        before { subject.save }
        it 'serializes the schedule as yaml' do
          subject.read_attribute(:schedule).should eq IceCube::Schedule.new(subject.starting).tap { |s|
            s.add_recurrence_rule IceCube::Rule.daily
          }.to_yaml
        end
      end
      context 'without a schedule' do
        subject { build(:event, event_recurrence: Event::RECURRENCE_NONE) }
        before { subject.save }
        it 'does not serialize the schedule' do
          subject.read_attribute(:schedule).should be_nil
        end
      end
    end
  end
  describe '.as_json' do
    it 'returns the object as json' do
      json = build(:event).as_json({})
      [:id, :title, :description, :start, :end, :type, :instructor, :location, :allDay, :recurring].each {|x| json.should have_key(x) }
    end
  end
end
