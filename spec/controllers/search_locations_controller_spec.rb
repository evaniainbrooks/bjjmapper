require 'spec_helper'
require 'shared/tracker_context'

describe SearchLocationsController do
  include_context 'skip tracking'
  describe 'GET show' do
    let(:query_params) { { query: 'query', format: 'json' } }
    context 'when there are geocoder results' do
      it 'returns the geocoder_results' do
        # Geocoder is already stubbed in test
        get :show, query_params
        assigns[:geocoder_results].length.should > 0
      end
    end
    context 'when there are locations results' do
      before do
        create(:location)
        Location.stub(:search_ids).and_return([Location.last.id])
      end
      it 'returns the locations' do
        get :show, query_params
        assigns[:locations].length.should > 0
      end
    end
    context 'when there are no results' do
      before do
        Geocoder.stub(:search).and_return([])
        Location.stub(:search_ids).and_return([])
      end
      it 'responds 204 no content' do
        get :show, query_params
      end
    end
  end
end
