require 'spec_helper'
require 'shared/tracker_context'

describe GeocodersController do
  include_context 'skip tracking'
  render_views
  describe 'GET show' do
    context 'with json format' do
      context 'when the geocoder service returns results' do
        let(:lat) { 80.0 }
        let(:lng) { 81.0 }
        let(:search_result) {
          double('search result',
                 city: 'Halifax',
                 address: '1234 Something xyz',
                 street_address: '1234 Something',
                 postal_code: '456 789',
                 state: 'NS',
                 country: 'Canada',
                 coordinates: [lat, lng],
                 geometry: { 'location' => { lat: lat, lng: lng } }
                )
        }
        before { Geocoder.stub('search') { [search_result, search_result] } }
        it 'returns an array of the search results' do
          get :show, query: 'test', format: 'json'

          [:address, :street_address, :postal_code, :city, :state, :country].each do |component|
            response.body.should match(search_result.send(component))
          end
          response.body.should match(lat.to_s)
          response.body.should match(lng.to_s)
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

