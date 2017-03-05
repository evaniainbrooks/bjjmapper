require 'spec_helper'

describe Api::ModerationNotificationsController do
  describe 'POST create' do
    let(:api_key) { 'some-key-123' }
    let(:user) { create(:user, api_key: api_key) }
    let(:notification_params) do
      {
        notification: { 
          info: { 
            duplicate_location_id: 123, 
            location_id: location.id 
          }, 
          message: 'Duplicate location',
          source: 'Test',
          lat: 80.0,
          lng: 80.0,
          type: 1
        }
      }
    end

    context 'with json format' do
      let(:location) { create(:location) }
      it 'creates the notification' do
        expect {
          post :create, { api_key: user.api_key, format: 'json' }.merge(notification_params)
          response.status.should eq 201
        }.to change { ModerationNotification.count }.by(1)
      end
    end
  end
end
