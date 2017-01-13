require 'spec_helper'

describe Redis do 
  describe '.cache' do
    let(:key) { 'my-key' }
    let(:expire) { 1000 }
    let(:expected_value) { 123456789 }
    subject { Redis.new }
    context 'when redis is up' do
      context 'when the item is not cached' do
        before { subject.stub(:get).and_return(nil) }
        it 'caches the result as yaml' do
          subject.should_receive(:set).with(key, anything)
          
          subject.cache(key: key) { expected_value }
        end
        it 'sets the expiry' do
          subject.stub(:set)
          subject.should_receive(:expire).with(key, expire)
          
          subject.cache(key: key, expire: expire) { expected_value }
        end
      end
      context 'when the item is cached' do
        before { subject.stub(:get).and_return(YAML::dump(expected_value)) }
        
        it 'does not cache the result' do
          subject.should_not_receive(:set).with(key, anything)
          
          val = subject.cache(key: key) { 'other value' }

          val.should eq expected_value
        end
      end
    end
    context 'when redis is down' do
      before { subject.stub(:get).and_raise(StandardError) }
      it 'returns the default value' do
        val = subject.cache(key: key, default: expected_value) { 'different value' }

        val.should eq expected_value
      end
    end
  end
end
