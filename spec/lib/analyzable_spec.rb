require 'spec_helper'
require 'analyzable'

describe RollFindr::Analyzable do
  let(:user) { OpenStruct.new(id: 123) }
  let(:test_class) do
    Class.new do
      include RollFindr::Analyzable
      def current_user; OpenStruct.new(id: 123); end
    end
  end
  subject { test_class.new }
  it 'has a tracker' do
    RollFindr::Tracker.should_receive(:new).with(user.to_param)
    subject.send(:tracker)
  end
end
