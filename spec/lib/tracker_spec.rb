require 'spec_helper'
require 'tracker'

describe RollFindr::Tracker do
  describe '#track' do
    let(:uid) { '12345' }
    let(:event) { 'SomeEvent' }
    let(:params) { { 'key' => 'value' } }
    describe '.track' do
      let(:super_property) { { 'superProp' => 'value2' } }
      subject { RollFindr::Tracker.new(uid, super_property) }
      context 'with super properties' do
        before { Mixpanel::Tracker.any_instance.should_receive(:track).with(uid, event, super_property.merge(params)) }
        it 'calls track with all merged properties' do
          subject.track(event, params)
        end
      end
      context 'without super properties' do
        subject { RollFindr::Tracker.new(uid) }
        before { Mixpanel::Tracker.any_instance.should_receive(:track).with(uid, event, params) }
        it 'calls track with the properties' do
          subject.track(event, params)
        end
      end
    end
    describe '.alias' do
      subject { RollFindr::Tracker.new(uid) }
      before do
        Mixpanel::Tracker.any_instance.should_receive(:alias).with('newuid', uid)
        Mixpanel::Tracker.any_instance.should_receive(:track).with('newuid', event, params)
      end
      it 'calls alias and sets the new user id' do
        subject.alias('newuid', uid)
        subject.track(event, params)
      end
    end
  end
end
