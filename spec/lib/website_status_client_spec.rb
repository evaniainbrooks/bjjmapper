require 'spec_helper'

describe RollFindr::WebsiteStatusClient do
  subject { RollFindr::WebsiteStatusClient.new('localhost', 9999) }
  describe '.search_async' do
    context 'when the service is up' do
      let(:body) { { code: 200, status: 'available', timestamp: Time.now }.to_json }
      let(:response) { double('http_response', code: 200, body: body) }
      before { Net::HTTP.should_receive(:get_response).and_return(response) }
      it 'fetches the response from the service' do
        subject.status(location_id: 123, url: 'loc1234.com').should eq JSON.parse(body).deep_symbolize_keys
      end
    end
    context 'when the service is down' do
      before { Net::HTTP.should_receive(:get_response).and_raise(StandardError, 'service is down') }
      it 'returns nil' do
        subject.status(url: 'loc1234').should be_nil
      end
    end
  end
end
