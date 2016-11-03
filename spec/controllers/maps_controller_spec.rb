require 'spec_helper'
require 'shared/tracker_context'
require 'shared/timezonesvc_context'

describe MapsController do
  include_context 'skip tracking'
  include_context 'timezone service'

  describe 'GET show' do
    it 'renders the map' do
      get :show

      response.status.should eq 200
      response.should render_template('maps/show')
    end
    context 'with lat and lng' do
      it 'does not geolocate' do
        get :show, lat: 80.0, lng: 80.0

        controller.send(:map).tap do |m|
          m.lat.should eq 80.0
          m.lng.should eq 80.0
          m.geolocate.should eq 0
        end
      end
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
        let(:closed_location) { create(:location, title: 'Closed', flag_closed: true) }
        it 'returns the locations' do
          get :search, location_type: [location.loctype], lat: location.lat, lng: location.lng, format: 'json'

          response.status.should eq 200
          assigns[:locations].collect(&:to_param).should include(location.to_param)
        end

        it 'does not return closed locations' do
          get :search, location_type: [location.loctype], lat: closed_location.lat, lng: closed_location.lng, format: 'json'

          response.status.should eq 200
          assigns[:locations].collect(&:to_param).should_not include(closed_location.to_param)
        end
      end
      context 'with count param' do
        let(:count) { 1 }
        let(:locations) { create_list(:location, count + 2) }
        it 'limits the results' do
          get :search, count: count, location_type: [locations.first.loctype], lat: locations.first.lat, lng: locations.first.lng, format: 'json'

          response.status.should eq 200
          assigns[:locations].size.should eq count
        end
      end
      context 'with no locations' do
        before { Location.destroy_all }
        xit 'returns no content' do
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
        it 'returns only the locations of the specified type' do
          get :search, location_type: [matched_location.loctype], lat: matched_location.lat, lng: matched_location.lng, format: 'json'

          response.status.should eq 200
          assigns[:locations].collect(&:to_param).should include(matched_location.to_param)
          assigns[:locations].collect(&:to_param).should_not include(other_location.to_param)
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
      context 'with geocode request' do
        let(:lat) { 80.0 }
        let(:lng) { 80.0 }
        let(:location_query) { 'New York' }
        before do
          GeocodersHelper.stub(:search).and_return([OpenStruct.new({lat: lat, lng: lng})])
        end
        it 'sets the lat and lng from the geocoded result' do
          get :search, geoquery: location_query, location_type: Location::LOCATION_TYPE_ALL, format: 'json'

          controller.send(:map).lat.should eq lat
          controller.send(:map).lng.should eq lng
        end
      end
      context 'with no lat, lng, location params' do
        context 'and no search terms' do
          it 'returns 400 bad request' do
            get :search, format: 'json'
            response.status.should eq 400
          end
        end
        context 'and with search terms' do
          let(:location) { build(:location) }
          before do
            Location.stub_chain(:not_closed, :limit, :where).and_return([location])
            Location.stub(:first).and_return(location)
          end
          xit 'sets the lat and lng from the first returned location' do
            get :search, query: 'some query not important because stubbed', format: 'json'
            controller.send(:map).lat.should eq lat
            controller.send(:map).lng.should eq lng
          end
        end
      end
      describe 'event_start and event_end' do
        let(:location) { create(:location) }
        let(:event_type) { Event::EVENT_TYPE_TOURNAMENT }
        let(:starting) { Time.now - 1.month }
        let(:ending) { Time.now + 1.month }
        let(:common_params) { { event_type: [event_type], location_type: [location.loctype], lat: location.lat, lng: location.lng, format: 'json' } }
        context 'when event_start is not passed' do
          let(:before_event) { build(:event, title: 'before', event_type: event_type, starting: 17.days.ago, ending: 16.days.ago) }
          let(:between_event) { build(:event, title: 'between', event_type: event_type, starting: 14.days.ago, ending: 13.days.ago) }
          before do
            Time.use_zone(stubbed_timezone) do
              location.events << before_event
              location.events << between_event
              location.save
            end
          end
          it 'defaults to 15 days ago' do
            get :search, common_params.merge(event_end: ending)

            assigns[:events][location.id].collect(&:to_param).tap do |event_params|
              event_params.should include(between_event.to_param)
              event_params.should_not include(before_event.to_param)
            end
          end
        end
        context 'when event_end is not passed' do
          let(:between_event) { build(:event, title: 'between', event_type: event_type, starting: Time.now + 1.day, ending: Time.now + 2.days) }
          let(:after_event) { build(:event, title: 'after', event_type: event_type, starting: Time.now + 1.year + 1.day, ending: Time.now + 1.year + 2.days) }
          before do
            Time.use_zone(stubbed_timezone) do
              location.events << between_event
              location.events << after_event
              location.save
            end
          end
          it 'defaults to 1 year from now' do
            get :search, common_params.merge(event_start: starting)

            assigns[:events][location.id].collect(&:to_param).tap do |event_params|
              event_params.should include(between_event.to_param)
              event_params.should_not include(after_event.to_param)
            end
          end
        end
        context 'when they are both passed' do
          let(:before_event) { build(:event, title: 'before', event_type: event_type, starting: starting - 2.days, ending: starting - 1.days) }
          let(:between_event) { build(:event, title: 'between', event_type: event_type, starting: starting + 1.day, ending: starting + 2.days) }
          let(:after_event) { build(:event, title: 'after', event_type: event_type, starting: ending + 1.day, ending: ending + 2.days) }
          before do
            Time.use_zone(stubbed_timezone) do
              location.events << before_event
              location.events << between_event
              location.events << after_event
              location.save
            end
          end
          it 'only returns events that lie within the range' do
            get :search, common_params.merge(event_start: starting, event_end: ending)

            assigns[:events][location.id].collect(&:to_param).tap do |event_params|
              event_params.should include(between_event.to_param)
              event_params.should_not include(before_event.to_param)
              event_params.should_not include(after_event.to_param)
            end
          end
        end
      end
      describe 'event_type' do
        let(:location_type) { Location::LOCATION_TYPE_ACADEMY }
        let(:event_type) { Event::EVENT_TYPE_SEMINAR }
        let(:location) { create(:location, loctype: location_type) }
        let(:event) { create(:event, event_type: event_type, location: location) }
        let(:common_params) { { lat: location.lat, lng: location.lng, format: 'json' } }
        context 'when not passed' do
          it 'defaults to no events' do
            get :search, common_params.merge(location_type: [location_type])
            assigns[:events][location.id].should be_blank
          end
        end
        context 'when an event type is passed' do
          it 'returns the matching event' do
            get :search, common_params.merge(event_type: [event.event_type])

            assigns[:events][location.id].to_param.should eq event.to_param
          end
          context 'with event venue location' do
            let(:event_venue_location) { create(:location, coordinates: location.coordinates, loctype: Location::LOCATION_TYPE_EVENT_VENUE) }
            let(:common_params) { { location_type: [location_type], event_type: [event.event_type], lat: event_venue_location.lat, lng: event_venue_location.lng, format: 'json' } }
            context 'with no events' do
              it 'does not return the location' do
                get :search, common_params

                assigns[:locations].collect(&:to_param).should_not include(event_venue_location.to_param)
              end
            end
            context 'with events' do
              before { event_venue_location.events << create(:event, event_type: event.event_type) }
              it 'returns the location' do
                get :search, common_params

                assigns[:locations].collect(&:to_param).should include(event_venue_location.to_param)
              end
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
              get :search, common_params.merge(event_type: [event_type])

              assigns[:locations].collect(&:to_param).should include(location.to_param)
              assigns[:locations].collect(&:to_param).should_not include(academy_location_no_events.to_param)
            end
          end
        end
        context 'when multiple event types are passed' do
          let(:tournament_event) { create(:event, event_type: Event::EVENT_TYPE_TOURNAMENT, location: location) }
          let(:multiple_event_types) { [event.event_type, tournament_event.event_type] }
          it 'returns the matching events' do
            get :search, common_params.merge(event_type: multiple_event_types)

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

