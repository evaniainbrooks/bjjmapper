shared_context 'timezone service' do
  let(:stubbed_timezone) { 'America/Los_Angeles' }
  before do
    RollFindr::TimezoneService.stub(:timezone_for).and_return(stubbed_timezone)
  end
end
