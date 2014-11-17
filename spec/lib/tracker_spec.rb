require 'spec_helper'
require 'tracker'

describe RollFindr::Tracker do
  describe '#track' do
    let(:uid) { '12345' }
    let(:event) { 'SomeEvent' }
    let(:params) { { 'key' => 'value' } }
    subject { RollFindr::Tracker.new(uid) }
    describe '.track' do
      it 'calls track on the underlying implementation' do
        Mixpanel::Tracker.any_instance.should_receive(:track).with(uid, event, params)
        subject.track(event, params)
      end
    end
    describe '.alias' do
      it 'calls alias and sets the new user id' do
        Mixpanel::Tracker.any_instance.should_receive(:alias).with('newuid', uid)
        Mixpanel::Tracker.any_instance.should_receive(:track).with('newuid', event, params)
        
        subject.alias('newuid', uid)
        subject.track(event, params)
      end
    end
  end
end
