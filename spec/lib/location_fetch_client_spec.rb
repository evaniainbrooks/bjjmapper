require 'spec_helper'

describe RollFindr::LocationFetchClient do
  describe '.search_async' do
    subject { RollFindr::LocationFetchClient.new('localhost', 9999) }
    let(:response) { double('http_response', code: 202) }
    before { Net::HTTP.any_instance.should_receive(:request).with(instance_of(Net::HTTP::Post)).and_return(response) }
    it 'fetches the response from the service' do
      subject.search_async('loc1234')
    end
  end
end
