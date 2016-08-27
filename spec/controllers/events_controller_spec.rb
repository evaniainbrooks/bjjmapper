require 'spec_helper'
require 'shared/tracker_context'

describe EventsController do
  include_context 'skip tracking'
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
          assigns(:events).count.should eq 2
          response.body.should match('included123')
          response.body.should match('included456')
          response.body.should_not match('excluded789')
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
