require 'spec_helper'
require 'shared/tracker_context'
require 'shared/timezonesvc_context'

describe LocationEventsController do
  include_context 'skip tracking'
  include_context 'timezone service'
  describe 'POST create' do
    context 'with json format' do
      context 'with valid params' do
        let(:location) { create(:location_with_instructors) }
        let(:valid_params) do
          {
            location_id: location.to_param,
            format: 'json',
            event: {
              instructor: location.instructors.first.to_param,
              starting: 10.hours.ago.utc.to_s,
              ending: 9.hours.ago.utc.to_s,
              title: 'test title',
              description: 'test description'
            }
          }
        end
        context 'when logged in' do
          let(:user) { create(:user) }
          let(:session_params) { { user_id: user.to_param } }
          context 'with a non-recurring event' do
            it 'creates a new event' do
              expect do
                post :create, valid_params, session_params
                response.should be_ok
              end.to change { Event.count }.by(1)
            end
          end
          context 'with a recurring event' do
            let(:recurring_event_params) do
              use_timezone do
                valid_params.deep_merge({
                  interval_start: Time.now.beginning_of_day.iso8601,
                  interval_end: 1.week.from_now.iso8601,
                  event: {
                    event_recurrence: Event::RECURRENCE_DAILY
                  }
                })
              end
            end

            it 'creates a new event and returns all occurrences between the passed interval' do
              expect do
                post :create, recurring_event_params, session_params
                response.should be_ok
                assigns[:events].count.should eq 8
              end.to change { Event.count }.by(1)
            end
          end
        end
        context 'when not logged in' do
          it 'returns not_authorized' do
            expect do
              post :create, valid_params, {}
              response.status.should eq 401
            end.to change { Event.count }.by(0)
          end
        end
      end
      context 'with invalid params' do
        let(:user) { create(:user) }
        let(:session_params) { { user_id: user.id } }
        let(:location) { create(:location_with_instructors) }
        let(:invalid_params) do
          {
            location_id: location.to_param,
            format: 'json',
            event: {
              description: 'test description'
            }
          }
        end
        it 'returns bad request' do
          expect do
            post :create, invalid_params, session_params
            response.status.should eq 400
          end.to change { Event.count }.by(0)
        end
      end
    end
  end
  describe 'GET index' do
    let(:start_time) { 5.hours.ago.iso8601 }
    let(:end_date) { Time.now.iso8601 }
    let(:location) { create(:location) }
    context 'with date range' do
      context 'with matching events in date range' do
        before do
          create(:event, location: location, title: 'included event 123', starting: 2.hours.ago.to_i, ending: 1.hours.ago.to_i)
          create(:event, location: location, title: 'excluded event 456', starting: 10.hours.ago.to_i, ending: 9.hours.ago.to_i)
        end
        it 'returns events that are within the date range' do
          get :index, { location_id: location.id, format: 'json', start: start_time, end: end_date }
          assigns[:events].count.should eq 1
          assigns[:events].first.title.should eq 'included event 123'
        end
      end
      context 'with no matching events in date range' do
        it 'returns 204 no content' do
          get :index, { location_id: location.id, format: 'json', start: 99.hours.ago.iso8601, end: 100.hours.ago.iso8601 }
          response.status.should eq 204
        end
      end
    end
    context 'without date range' do
      it 'returns bad request' do
        get :index, { location_id: location.id, format: 'json', start: start_time }
        response.should_not be_ok
      end
    end
  end
end

