require 'spec_helper'
require 'event_schedule'
require 'shared/timezonesvc_context'

describe RollFindr::EventSchedule do
  include_context 'timezone service'
  let(:empty_query) do
    double.tap do |q|
      q.stub(:between_time).and_return([])
      q.stub(:reduce).and_return([])
    end
  end
  describe '.events_between_time' do
    context 'when there are single events' do
      let(:single_events) { build_list(:event, 10) }
      let(:single_events_query) do
        double.tap { |q| q.stub(:between_time).and_return(single_events) }
      end
      subject { RollFindr::EventSchedule.new(single_events_query, empty_query) }
      it 'returns the single events' do
        events = subject.events_between_time(1.day.ago, Time.now)
        events.count.should eq single_events.count
      end
    end
    context 'when there are recurring events' do
      let(:recurring_event) { build(:event, title: 'Recurring Event', event_recurrence: Event::RECURRENCE_WEEKLY, weekly_recurrence_days: ["0"]) }
      before { recurring_event.save }
      subject { RollFindr::EventSchedule.new(empty_query, [recurring_event]) }
      it 'returns all recurring instances' do
        events = subject.events_between_time(Time.now, Time.now + 10.weeks)
        events.count.should eq 10
      end
    end
    context 'when there are no events' do
      subject { RollFindr::EventSchedule.new(empty_query, empty_query) }
      it 'returns empty array' do
        subject.events_between_time(10.hours.ago, 2.hours.ago).should be_empty
      end
    end
  end
end
