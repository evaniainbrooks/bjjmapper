require 'spec_helper'
require 'tracker'

describe RollFindr::Tracker do
  describe '#track' do
    let(:uid) { '12345' }
    let(:event) { 'SomeEvent' }
    let(:params) { { 'key' => 'value' } }
    subject { RollFindr::Tracker.new(uid) }
    it 'calls track on the underlying implementation' do
      Mixpanel::Tracker.any_instance.should_receive(:track).with(uid, event, params)
      subject.track(event, params)
    end
  end
end
