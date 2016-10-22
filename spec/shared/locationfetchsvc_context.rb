shared_context 'locationfetch service' do
  before do
    RollFindr::LocationFetchService.stub(:search_async).and_return(202)
  end
end
