require 'spec_helper'

describe EventsController do
  describe 'POST create' do
    context 'with json format' do
      context 'with valid params' do
        let(:location) { create(:location_with_instructors) }
        let(:valid_params) do 
          {
            location_id: location.to_param,
            format: 'json', 
            event: { 
              location_id: location.to_param,
              instructor_id: location.instructors.first.to_param, 
              starting: 10.hours.ago.to_i,
              ending: 9.hours.ago.to_i,
              title: 'test title',
              description: 'test description'
            }
          }
        end
        context 'when logged in' do
          let(:user) { create(:user) }
          let(:session_params) { { user_id: user.id } }
          it 'creates a new event' do
            expect do
              post :create, valid_params, session_params
              response.should be_ok
            end.to change { Event.count }.by(1)
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
          get :index, { location_id: location.id, format: 'json', start: 99.hours.ago.iso8601, end: 100.hours.ago.iso8601 }
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

