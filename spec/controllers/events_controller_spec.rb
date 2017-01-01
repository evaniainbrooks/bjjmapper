require 'spec_helper'
require 'shared/tracker_context'
require 'shared/timezonesvc_context'
require 'shared/redis_context'

describe EventsController do
  include_context 'skip tracking'
  include_context 'timezone service'
  include_context 'redis'

  describe 'GET wizard' do
    context 'when not signed in' do
      it 'redirects to the login page' do
        get :wizard
        response.should redirect_to(signin_path)
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      it 'shows the wizard' do
        get :wizard, {}, session_params
        response.should be_ok
      end
    end
  end
  describe 'POST create' do
    context 'when signed in' do
      let(:user) { create(:user) }
      let(:session_params) { { user_id: user.to_param } }
      let(:event_params) do
        {
          format: 'json',
          event: {
            event_type: Event::EVENT_TYPE_CLASS,
            starting: 10.hours.ago.utc.to_s,
            ending: 9.hours.ago.utc.to_s,
            title: 'test title',
            description: 'test description'
          }
        }
      end
      context 'with location_id' do
        let(:location) { create(:location) }
        it 'creates an event at the existing location' do
          expect do
            post :create, event_params.merge(:location_id => location.to_param), session_params
          end.to change { Location.find(location.to_param).events.count }.by(1)
        end
        it 'does not create a new location' do
          location
          expect do
            post :create, event_params.merge(:location_id => location.to_param), session_params
          end.to change { Location.count }.by(0)
        end
      end
      context 'without location_id' do
        let(:location_params) do
          {
            :location => {
              :loctype => 1,
              :city => 'New York',
              :country => 'USA',
              :title => 'New title',
              :description => 'New description'
            }
          }
        end
        it 'creates an event at a new location' do
          expect do
            post :create, event_params.merge(location_params), session_params
          end.to change { Event.count }.by(1)
        end
        it 'creates a new location' do
          expect do
            post :create, event_params.merge(location_params), session_params
          end.to change { Location.count }.by(1)
        end
      end
    end
    context 'when not signed in' do
      it 'returns not_authorized' do
        expect do
          post :create, { format: 'json' }, {}
          response.status.should eq 401
        end.to change { Event.count }.by(0)
      end
    end
  end
  describe 'GET upcoming' do
    before do
      create(:event, event_type: Event::EVENT_TYPE_TOURNAMENT, starting: 1.year.ago, ending: 1.year.ago + 1.day)
      create(:event, event_type: Event::EVENT_TYPE_TOURNAMENT, starting: Time.now + 5.days, ending: Time.now + 6.days)
      create(:event, event_type: Event::EVENT_TYPE_CLASS, starting: Time.now + 5.days, ending: Time.now + 6.days)
    end
    it 'returns all upcoming events that are not a class' do
      get :upcoming, { format: 'json' }, {}

      assigns[:events].count.should eq 1
      assigns[:events][0].event_type.should eq Event::EVENT_TYPE_TOURNAMENT
    end
    context 'with event_type param' do
      before do
        create(:event, event_type: Event::EVENT_TYPE_TOURNAMENT, starting: Time.now + 5.days, ending: Time.now + 6.days)
        create(:event, event_type: Event::EVENT_TYPE_SEMINAR, starting: Time.now + 5.days, ending: Time.now + 6.days)
        create(:event, event_type: Event::EVENT_TYPE_CLASS, starting: Time.now + 5.days, ending: Time.now + 6.days)
      end
      xit 'returns all upcoming events that match event_type' do
        get :upcoming, { format: 'json', event_type: [Event::EVENT_TYPE_TOURNAMENT] }, {}

        assigns[:events].count.should eq 1
        assigns[:events][0].event_type.should eq Event::EVENT_TYPE_TOURNAMENT
      end
    end
  end
  describe 'GET index' do
    let(:start_time) { 5.hours.ago.iso8601 }
    let(:end_date) { Time.now.iso8601 }
    let(:locations) { create_list(:location, 5) }
    let(:ids) { locations.collect(&:to_param) }
    context 'with date range' do
      context 'with matching events in date range' do
        before do
          create(:event, location: locations[0], title: 'included123', starting: 2.hours.ago.to_i, ending: 1.hours.ago.to_i)
          create(:event, location: locations[1], title: 'included456', starting: 2.hours.ago.to_i, ending: 1.hours.ago.to_i)
          create(:event, location: locations[1], title: 'excluded789', starting: 10.hours.ago.to_i, ending: 9.hours.ago.to_i)
        end
        it 'returns events for all locations that are within the date range' do
          get :index, { ids: ids, format: 'json', start: start_time, end: end_date }
          assigns(:events).collect(&:title).tap do |a|
            a.count.should eq 2
            a.should include('included123')
            a.should include('included456')
          end
        end
      end
      context 'with no matching events in date range' do
        it 'returns 204 no content' do
          get :index, { ids: ids, format: 'json', start: 99.hours.ago.iso8601, end: 100.hours.ago.iso8601 }
          response.status.should eq 204
        end
      end
    end
    context 'without date range' do
      it 'returns bad request' do
        get :index, { ids: ids, format: 'json', start: start_time }
        response.should_not be_ok
      end
    end
  end
end
