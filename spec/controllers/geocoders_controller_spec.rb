require 'spec_helper'
require 'shared/tracker_context'

describe GeocodersController do
  include_context 'skip tracking'
  describe 'GET show' do
    context 'with json format' do
      context 'when the geocoder service returns results' do
        let(:location) { { 'lat' => 80.0, 'lng' => 80.0 } }
        before do
          search_result = double('search result', city: '', address: '', street_address: '', state: '', postal_code: '', country: '')
          search_result.stub('geometry') { { 'location' => location } }
          search_result.stub('coordinates') { [location['lat'], location['lng']] }
          Geocoder.stub('search') { [search_result, search_result] }
        end
        it 'returns an array of the search results' do
          get :show, query: 'test', format: 'json'
          
          assigns[:search_results].length.should eq 2
          response.should be_ok
        end
      end
      context 'when the geocoder service returns nothing' do
        before { Geocoder.stub(:search) { [] } }
        it 'returns 404' do
          get :show, query: 'test', format: 'json'
          response.status.should eq 404
        end
      end
    end
  end
end

