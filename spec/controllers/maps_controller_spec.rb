require 'spec_helper'
require 'shared/tracker_context'

describe MapsController do
  include_context 'skip tracking'
  describe 'GET show' do
    it 'renders the map' do
      get :show

      response.status.should eq 200
      response.should render_template('maps/show')
    end
  end
  describe 'GET search' do
    context 'with invalid params' do
      it 'returns bad request' do
        get :search, format: 'json', lat: 888.0
        response.status.should eq 400
      end
    end
    context '(json)' do
      context 'with locations < distance from center' do
        let(:location) { create(:location, title: 'Wow super location') }
        it 'returns the locations' do
          get :search, location_type: [location.loctype], lat: location.lat, lng: location.lng, format: 'json'

          response.status.should eq 200
          assigns[:locations].collect(&:to_param).should include(location.to_param)
        end
      end
      context 'with no locations' do
        before { Location.destroy_all }
        it 'returns no content' do
          get :search, lat: 80.0, lng: 80.0, format: 'json'
          response.status.should eq 204
        end
      end
      context 'with team filter' do
        let(:blue_team) { create(:team, name: 'Blue') }
        let(:red_team) { create(:team, name: 'Red') }
        let(:red_location) { create(:location, team: red_team, title: 'Red location') }
        let(:blue_location) { create(:location, team: blue_team, title: 'Blue location', coordinates: red_location.coordinates) }
        it 'returns specific team locations' do
          get :search, location_type: [blue_location.loctype], lat: blue_location.lat, lng: blue_location.lng, team: [blue_team.id], format: 'json'

          response.status.should eq 200
          assigns[:locations].collect(&:to_param).should include(blue_location.to_param)
          assigns[:locations].collect(&:to_param).should_not include(red_location.to_param)
        end
      end
      context 'with location_type (loctype)' do
        let(:other_location) { create(:location, loctype: Location::LOCATION_TYPE_EVENT_VENUE, title: 'Other location') }
        let(:matched_location) { create(:location, loctype: Location::LOCATION_TYPE_ACADEMY, title: 'Matched location') }
        xit 'defaults to LOCATION_TYPE_ACADEMY' do
          get :search, lat: matched_location.lat, lng: matched_location.lng, format: 'json'

          response.status.should eq 200
          assigns[:locations].collect(&:to_param).should include(matched_location.to_param)
          assigns[:locations].collect(&:to_param).should_not include(other_location.to_param)
        end
        it 'returns only the locations of the specified type' do
          get :search, location_type: [matched_location.loctype], lat: matched_location.lat, lng: matched_location.lng, format: 'json'

          response.status.should eq 200
          assigns[:locations].collect(&:to_param).should include(matched_location.to_param)
          assigns[:locations].collect(&:to_param).should_not include(other_location.to_param)
        end
        it 'accepts an array of loctype values and returns all matching locations' do
          get :search, location_type: [matched_location.loctype, other_location.loctype], lat: matched_location.lat, lng: matched_location.lng, format: 'json'

          response.status.should eq 200
          assigns[:locations].collect(&:to_param).should include(matched_location.to_param)
          assigns[:locations].collect(&:to_param).should include(other_location.to_param)
        end
      end
      context 'with term filter (query)' do
        let(:term) { 'kirpi' }
        let(:matched_location) { create(:location, title: term) }
        let(:other_location) { create(:location, title: 'unmatched') }
        it 'returns locations that are a text match' do
          get :search, query: term, location_type: [matched_location.loctype, other_location.loctype], lat: matched_location.lat, lng: matched_location.lng, format: 'json'

          response.status.should eq 200
          assigns[:locations].collect(&:to_param).should include(matched_location.to_param)
          assigns[:locations].collect(&:to_param).should_not include(other_location.to_param)
        end
      end
      describe 'event_type' do
        let(:location_type) { Location::LOCATION_TYPE_ACADEMY }
        let(:event_type) { Event::EVENT_TYPE_SEMINAR }
        let(:location) { create(:location, loctype: location_type) }
        let(:event) { create(:event, event_type: event_type, location: location) }
        context 'when not passed' do
          it 'defaults to no events' do
            get :search, location_type: [location_type], lat: location.lat, lng: location.lng, format: 'json'
            assigns[:events][location.id].should be_blank
          end
        end
        context 'when an event type is passed' do
          it 'returns the matching event' do
            get :search, event_type: [event.event_type], lat: location.lat, lng: location.lng, format: 'json'

            assigns[:events][location.id].to_param.should eq event.to_param
          end
          context 'with event venue location' do
            let(:event_venue_location) { create(:location, coordinates: location.coordinates, loctype: Location::LOCATION_TYPE_EVENT_VENUE) }
            it 'finds the location' do
              get :search, location_type: [location_type], event_type: [event.event_type], lat: event_venue_location.lat, lng: event_venue_location.lng, format: 'json'

              assigns[:locations].collect(&:to_param).should include(event_venue_location.to_param)
            end
          end
          context 'when the location type does not include academies' do
            let(:academy_location_no_events) { create(:location, coordinates: location.coordinates, loctype: Location::LOCATION_TYPE_ACADEMY) }
            before do
              location
              event
              academy_location_no_events
            end

            it 'returns only academies with events' do
              get :search, event_type: [event_type], lat: location.lat, lng: location.lng, format: 'json'

              assigns[:locations].collect(&:to_param).should include(location.to_param)
              assigns[:locations].collect(&:to_param).should_not include(academy_location_no_events.to_param)
            end
          end
        end
        context 'when multiple event types are passed' do
          let(:tournament_event) { create(:event, event_type: Event::EVENT_TYPE_TOURNAMENT, location: location) }
          let(:multiple_event_types) { [event.event_type, tournament_event.event_type] }
          it 'returns the matching events' do
            get :search, event_type: multiple_event_types, lat: location.lat, lng: location.lng, format: 'json'

            assigns[:events][location.id].collect(&:to_param).tap do |events|
              events.should include(event.to_param)
              events.should include(tournament_event.to_param)
            end
          end
        end
      end
    end
  end
end
