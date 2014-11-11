require 'spec_helper'

describe EventsController do
  describe 'GET index' do
    let(:start_date) { 5.hours.ago.iso8601 }
    let(:end_date) { Time.now.iso8601 }
    let(:location) { create(:location) }
    context 'with date range' do
      context 'with matching events in date range' do
        before do
          create(:event, location: location, title: 'included event 123', starting: 2.hours.ago.to_i, ending: 1.hours.ago.to_i)
          create(:event, location: location, title: 'excluded event 456', starting: 10.hours.ago.to_i, ending: 9.hours.ago.to_i)
        end
        it 'returns events that are within the date range' do     
          get :index, { location_id: location.id, format: 'json', start: start_date, end: end_date }
          assigns(:events).count.should eq 1
          response.body.should match('included event 123')
          response.body.should_not match('excluded event 456')
        end
      end
      context 'with no matching events in date range' do
        it 'returns 204 no content' do
          get :index, { location_id: location.id, format: 'json', start: 99.hours.ago, end: 100.hours.ago }
          response.status.should eq 204
        end
      end
    end
    context 'without date range' do
      it 'returns bad request' do
        get :index, { location_id: location.id, format: 'json', start: start_date }
        response.should_not be_ok
      end
    end
  end
end

