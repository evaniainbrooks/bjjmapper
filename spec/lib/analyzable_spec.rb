require 'spec_helper'
require 'analyzable'

describe RollFindr::Analyzable do
  let(:accept_language) { 'en' }
  let(:ref) { 'testref' }
  let(:test_class) do
    Class.new do
      include RollFindr::Analyzable
      def current_user;  {:id => 123}; end
    end
  end
  let(:ua_parser) { Agent.new(ua_string) }

  subject { test_class.new }
  before do
    RollFindr::Tracker.should_receive(:new).with(subject.current_user.to_param, {})
  end
  it 'has a tracker' do
    subject.send(:tracker)
  end
end
