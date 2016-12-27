shared_context 'redis' do
  before do
    Redis.any_instance.stub(:cache) do |params, &block|
      block.call
    end
  end
end
