shared_context 'websitestatus service' do
  before do
    RollFindr::WebsiteStatusService.stub(:status).and_return(nil)
  end
end
