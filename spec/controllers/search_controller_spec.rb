require 'spec_helper'
require 'shared/tracker_context'
require 'shared/geocoder_context'

describe SearchController do
  include_context 'skip tracking'
  describe 'GET show' do
    let(:query_params) { { q: 'query', format: 'json' } }
    context 'when there are geocoder results' do
      include_context 'geocoder service'
      before do
        [Location, User, Team].each { |klass| klass.stub(:search_ids).and_return([]) }
      end
      it 'returns the addresses' do
        # Geocoder is already stubbed in test
        get :show, query_params
        
        assigns[:addresses].length.should > 0
      end
    end
    context 'when there are locations results' do
      before do
        create(:location)
        GeocodersHelper.stub(:search).and_return([])
        [User, Team].each { |klass| klass.stub(:search_ids).and_return([]) }
        Location.stub(:search_ids).and_return([Location.last.id])
      end
      it 'returns the locations' do
        get :show, query_params
        
        assigns[:locations].length.should > 0
      end
    end
    context 'when there are no results' do
      before do
        GeocodersHelper.stub(:search).and_return([])
        [Location, User, Team].each { |klass| klass.stub(:search_ids).and_return([]) }
      end
      it 'responds 204 no content' do
        get :show, query_params
      end
    end
  end
end
