require 'spec_helper'

describe RollFindr::TimezoneClient do
  describe '.timezone_for' do
    let(:expected_timezone) { 'America/Los Angeles' }
    subject { RollFindr::TimezoneClient.new('localhost', 9999) }
    before do
      response_dbl = double()
      response_dbl.stub(:body).and_return(expected_timezone)
      Net::HTTP.stub(:get_response).and_return(response_dbl)
    end
    it 'returns the timezone' do
      subject.timezone_for(80.0, 80.0).should eq expected_timezone
    end
  end
end
