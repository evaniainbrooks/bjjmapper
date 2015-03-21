shared_context 'skip tracking' do
  before do
    RollFindr::Tracker.any_instance.stub(:track).and_return(nil)
  end
end
