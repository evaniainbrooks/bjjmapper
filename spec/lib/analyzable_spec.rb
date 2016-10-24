require 'spec_helper'
require 'analyzable'

describe RollFindr::Analyzable do
  let(:accept_language) { 'en' }
  let(:ref) { 'testref' }
  let(:test_class) do
    Class.new do
      include RollFindr::Analyzable
      def current_user
        { :id => 123 }
      end
    end
  end
  let(:ua_parser) { Agent.new(ua_string) }

  subject { test_class.new }
  describe '.tracker' do
    before do
      RollFindr::Tracker.should_receive(:new).with(subject.current_user.to_param, anything)
    end
    it 'initializes and returns a tracker impl' do
      subject.send(:tracker)
    end
  end
  it 'has a super property named __skip_tracking' do
    subject.send(:analytics_super_properties).should have_key(:__skip_tracking)
  end
end
