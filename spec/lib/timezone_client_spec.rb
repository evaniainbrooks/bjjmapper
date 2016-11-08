require 'spec_helper'

describe RollFindr::TimezoneClient do
  describe '.timezone_for' do
    let(:expected_timezone) { 'America/Los Angeles' }
    subject { RollFindr::TimezoneClient.new('localhost', 9999) }
    context 'when the status is 200 OK' do
      before do
        response_dbl = double('response', code: 200)
        response_dbl.stub(:body).and_return(expected_timezone)
        Net::HTTP.stub(:get_response).and_return(response_dbl)
      end
      it 'returns the timezone' do
        subject.timezone_for(80.0, 80.0).should eq expected_timezone
      end
     end
    context 'when the server is down' do
      before { Net::HTTP.should_receive(:get_response).and_raise(StandardError, 'service is down') }
      it 'returns nil' do
        subject.timezone_for(80.0, 80.0).should be_nil
      end
    end
    context 'when the status is not 200 OK' do
      before do
        response_dbl = double('response', code: 502)
        response_dbl.stub(:body).and_return(expected_timezone)
        Net::HTTP.stub(:get_response).and_return(response_dbl)
      end
      it 'returns nil' do
        subject.timezone_for(80.0, 80.0).should be_nil
      end
    end
  end
end
