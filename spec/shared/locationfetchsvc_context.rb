shared_context 'locationfetch service' do
  before do
    RollFindr::LocationFetchService.stub(:search_async).and_return(202)
    RollFindr::LocationFetchService.stub(:reviews).and_return({})
    RollFindr::LocationFetchService.stub(:detail).and_return({})
  end
end
