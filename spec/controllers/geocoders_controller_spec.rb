require 'spec_helper'
require 'shared/tracker_context'
require 'shared/geocoder_context'

describe GeocodersController do
  include_context 'skip tracking'
  render_views
  describe 'GET show' do
    context 'with json format' do
      context 'when the geocoder service returns results' do
        include_context 'geocoder service'
        it 'returns an array of the search results' do
          get :show, query: 'test', format: 'json'

          [:address, :street_address, :postal_code, :city, :state, :country].each do |component|
            response.body.should match(geocode_search_result.send(component))
          end
          response.body.should match(geocode_lat.to_s)
          response.body.should match(geocode_lng.to_s)
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

