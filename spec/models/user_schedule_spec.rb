require 'spec_helper'

describe UserSchedule do
  subject { UserSchedule.new('user-id') }
  let(:start_time) { Time.now }
  let(:end_time) { start_time + 2.hours }
  before { Event.stub_chain(:where, :where, :asc).and_return([]) }
  describe '.events_between_time' do
    it 'calls through to event_schedule' do
      RollFindr::EventSchedule.any_instance.should_receive(:events_between_time).with(start_time, end_time)

      subject.events_between_time(start_time, end_time)
    end
  end
end
