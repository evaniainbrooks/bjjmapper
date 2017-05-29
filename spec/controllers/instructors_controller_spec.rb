require 'rails_helper'
require 'shared/tracker_context'

describe InstructorsController do
  include_context 'skip tracking'
  let(:anonymous_user) { create(:user, role: 'anonymous') }
  let(:session_params) { { :user_id => anonymous_user.to_param } }
  describe 'DELETE destroy' do
    context 'with json format' do
      before { @location = create(:location_with_instructors) }
      it 'removes the instructor from the location' do
        anonymous_user
        expect do
          delete :destroy, { format: 'json', id: @location.instructors.first.id, location_id: @location.id }, session_params
        end.to change{ Location.find(@location.id).instructors.count }.by(-1)
      end
      it 'does not delete the instructor' do
        anonymous_user
        expect do
          delete :destroy, { format: 'json', id: @location.instructors.first.id, location_id: @location.id }, session_params
        end.to change{ User.count }.by(0)
      end
    end
  end
  describe 'POST create' do
    let(:location) { create(:location) }
    let(:instructor) { create(:user) }
    context 'with json format' do
      context 'with a simple id' do
        it 'adds the instructor to the location' do
          expect do
            post :create, { format: 'json', id: instructor.id, location_id: location.id }, session_params
          end.to change{ Location.find(location.id).instructors.count }.by(1)
        end
      end
      context 'with only a name' do
        let(:expected_name) { 'Evan Brooks' }
        it 'creates and adds the instructor stub to the location' do
          expect do
            post :create, { format: 'json', name: expected_name, location_id: location.id }, session_params
          end.to change{ Location.find(location.id).instructors.count }.by(1)
        end
      end
      context 'with a user object' do
        let(:instructor_params) do
          {
            :user => {
              :name => 'Test Instructor',
              :email => 'test1@bjjmapper.com',
              :belt_rank => 'brown',
              :stripe_rank => 1
            }
          }
        end
        it 'creates the instructor and adds them to the location' do
          expect do
            post :create, { format: 'json', location_id: location.id }.merge(instructor_params), session_params
          end.to change{ Location.find(location.id).instructors.count }.by(1)
        end
      end
    end
  end
end

