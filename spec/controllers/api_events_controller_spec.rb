require 'spec_helper'
require 'shared/timezonesvc_context'
require 'shared/redis_context'

describe Api::EventsController do
  include_context 'timezone service'
  include_context 'redis'
  
  describe 'POST create' do
    context 'when signed in' do
      let(:api_key) { '1234' }
      let(:user) { create(:user, api_key: api_key) }
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
            post :create, event_params.merge(:location_id => location.to_param, format: 'json', api_key: user.api_key)
          end.to change { Location.find(location.to_param).events.count }.by(1)
        end
        it 'does not create a new location' do
          location
          expect do
            post :create, event_params.merge(:location_id => location.to_param, format: 'json', api_key: user.api_key)
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
              :coordinates => [80.0, 80.0],
              :description => 'New description'
            }
          }
        end
        it 'creates an event at a new location' do
          expect do
            post :create, event_params.merge(location_params).merge(format: 'json', api_key: user.api_key)
          end.to change { Event.count }.by(1)
        end
        it 'creates a new location' do
          expect do
            post :create, event_params.merge(location_params).merge(format: 'json', api_key: user.api_key)
          end.to change { Location.count }.by(1)
        end
      end
    end
  end
end
