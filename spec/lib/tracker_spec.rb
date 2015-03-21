require 'spec_helper'
require 'tracker'

describe RollFindr::Tracker do
  describe '#track' do
    let(:uid) { '12345' }
    let(:event) { 'SomeEvent' }
    let(:params) { { 'key' => 'value' } }
    describe '.track' do
      context 'with super properties' do
        let(:super_property) { { 'param' => 'value' } }
        context 'when the __skip_tracking property is true' do
          subject { RollFindr::Tracker.new(uid, super_property.merge(__skip_tracking: true)) }
          before { Mixpanel::Tracker.any_instance.stub(:track).and_raise(StandardError) }
          it 'does not call track' do
            subject.track(event, params)
          end
        end
        context 'when the __skip_tracking property is false' do
          subject { RollFindr::Tracker.new(uid, super_property.merge(__skip_tracking: false)) }
          context 'when track does not raise an exception' do
            before { Mixpanel::Tracker.any_instance.should_receive(:track).with(uid, event, hash_including(super_property.merge(params))) }
            it 'calls track with all merged properties' do
              subject.track(event, params)
            end
          end
          context 'when track raises an exception' do
            before { Mixpanel::Tracker.any_instance.stub(:track).and_raise(StandardError) }
            it 'does nothing' do
              subject.track(event, params)
            end
          end
        end
      end
      context 'without super properties' do
        subject { RollFindr::Tracker.new(uid) }
        before { Mixpanel::Tracker.any_instance.should_receive(:track).with(uid, event, hash_including(params)) }
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
