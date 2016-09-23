require 'spec_helper'

describe Event do
  it 'has a factory' do
    build(:event).should be_valid
  end
  describe 'scopes' do
    describe 'times' do
      before do
        create(:event, starting: 4.hours.ago, ending: 3.hours.ago)
        create(:event, starting: 2.hours.ago, ending: 1.hours.ago)
        create(:event, starting: 1.hours.ago, ending: Time.now)
      end
      describe '#before_time' do
        subject { Event.before_time(2.hours.ago) }
        it 'returns events before the start_time' do
          subject.count.should eq 2
          subject.first.ending.should > 2.hours.ago
        end
      end
      describe '#after_time' do
        subject { Event.after_time(2.hours.ago) }
        it 'returns events after the end_time' do
          subject.count.should eq 2
          subject.first.starting.should < 2.hours.ago
        end
      end
      describe '#between_time' do
        subject { Event.between_time(2.hours.ago, 1.hours.ago) }
        it 'returns events after start_time but before end_time' do
          subject.count.should eq 1
          subject.first.starting.should > 2.hours.ago
          subject.first.starting.should < 1.hours.ago
        end
      end
    end
    describe 'types' do
      before do
        create(:event, event_type: Event::EVENT_TYPE_CLASS)
        create(:event, event_type: Event::EVENT_TYPE_SEMINAR)
        create(:event, event_type: Event::EVENT_TYPE_CAMP)
        create(:event, event_type: Event::EVENT_TYPE_TOURNAMENT)
        create(:event, event_type: Event::EVENT_TYPE_SUBEVENT)
      end
      describe '#default_scope' do
        subject { Event.all }
        it 'does not return sub events' do
          subject.count.should eq 4
          subject.collect(&:event_type).should_not include(Event::EVENT_TYPE_SUBEVENT)
        end
      end
      describe '#classes' do
        subject { Event.classes }
        it 'returns only events with type=class' do
          subject.count.should eq 1
          subject.first.event_type.should eq Event::EVENT_TYPE_CLASS
        end
      end
      describe '#seminars' do
        subject { Event.seminars }
        it 'returns only events with type=seminar' do
          subject.count.should eq 1
          subject.first.event_type.should eq Event::EVENT_TYPE_SEMINAR
        end
      end
      describe '#camps' do
        subject { Event.camps }
        it 'returns only events with type=camp' do
          subject.count.should eq 1
          subject.first.event_type.should eq Event::EVENT_TYPE_CAMP
        end
      end
      describe '#tournaments' do
        subject { Event.tournaments }
        it 'returns only events with type=tournament' do
          subject.count.should eq 1
          subject.first.event_type.should eq Event::EVENT_TYPE_TOURNAMENT
        end
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
    describe '.set_event_type' do
      context 'when there is a parent event' do
        subject { create(:event, event_type: Event::EVENT_TYPE_CLASS, parent_event: create(:event)) }
        it 'sets event_type to EVENT_TYPE_SUBEVENT' do
          subject.event_type.should eq Event::EVENT_TYPE_SUBEVENT
        end
      end
      context 'when there is no parent event' do
        subject { create(:event, event_type: Event::EVENT_TYPE_CLASS, parent_event: nil) }
        it 'retains the original event_type' do
          subject.event_type.should eq Event::EVENT_TYPE_CLASS
        end
      end
    end
    describe '.create_schedule' do
      context 'when .event_recurrence is NONE' do
        subject { build(:event, event_recurrence: Event::RECURRENCE_NONE) }
        before { subject.save }
        it 'does not create a schedule' do
          subject.schedule.rrules.should be_empty
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
      context 'when there is an existing schedule' do
        subject { create(:event, event_recurrence: Event::RECURRENCE_WEEKLY, weekly_recurrence_days: ["0", "1"]) }
        before do
          subject.event_recurrence = Event::RECURRENCE_DAILY
          subject.save
        end
        it 'only persists the newest recurrence rule' do
          subject.schedule.rrules.count.should eq 1
          subject.schedule.rrules.first.class.should eq IceCube::DailyRule
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
          subject.schedule.rrules.should be_empty
        end
      end
    end
  end
  describe '.as_json' do
    it 'returns the object as json' do
      json = build(:event).as_json({})
      [:id, :title, :description, :start, :end, :event_type, :instructor, :location, :allDay, :recurring, :recurrence_type, :recurrence_days].each {|x| json.should have_key(x) }
    end
  end
end
