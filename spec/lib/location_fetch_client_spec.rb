require 'spec_helper'

describe RollFindr::LocationFetchClient do
  subject { RollFindr::LocationFetchClient.new('localhost', 9999) }
  describe '.search_async' do
    let(:response) { double('http_response', code: 202) }
    before { Net::HTTP.any_instance.should_receive(:request).with(instance_of(Net::HTTP::Post)).and_return(response) }
    it 'fetches the response from the service' do
      subject.search_async('loc1234')
    end
  end
  describe '.reviews' do
    context 'with success response' do
      let(:response) { double('http_response', :code => 200, :body => "{}") }
      before { Net::HTTP.should_receive(:get_response).and_return(response) }
      it 'returns the response' do
        subject.reviews('loc1234').should_not be_nil
      end
    end
    context 'with failure response' do
      let(:response) { double('http_response', :code => 400, :body => "{}") }
      before { Net::HTTP.should_receive(:get_response).and_return(response) }
      it 'returns nil' do
        subject.reviews('loc1234').should be_nil
      end
    end
  end
  describe '.detail' do
    context 'with success response' do
      let(:response) { double('http_response', :code => 200, :body => "{}") }
      before { Net::HTTP.should_receive(:get_response).and_return(response) }
      it 'returns the response' do
        subject.detail('loc1234').should_not be_nil
      end
    end
    context 'with failure response' do
      let(:response) { double('http_response', :code => 400, :body => "{}") }
      before { Net::HTTP.should_receive(:get_response).and_return(response) }
      it 'returns nil' do
        subject.detail('loc1234').should be_nil
      end
    end
  end
end
