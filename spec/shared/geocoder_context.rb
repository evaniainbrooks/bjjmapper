shared_context 'geocoder service' do
  let(:geocode_lat) { 80.0 }
  let(:geocode_lng) { 81.0 }
  let(:geocode_search_result) {
    double('search result',
           city: 'Halifax',
           address: '1234 Something xyz',
           street_address: '1234 Something',
           postal_code: '456 789',
           state: 'NS',
           country: 'Canada',
           country_code: 'CA',
           coordinates: [geocode_lat, geocode_lng],
           geometry: { 'location' => { lat: geocode_lat, lng: geocode_lng } }
          )
  }
  before { Geocoder.stub('search') { [geocode_search_result, geocode_search_result] } }
end
