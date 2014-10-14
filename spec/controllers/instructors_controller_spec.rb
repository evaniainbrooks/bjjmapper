require 'rails_helper'

describe InstructorsController do
  describe 'DELETE destroy' do
    context 'with json format' do
      before { @location = create(:location_with_instructors) }
      it 'removes the instructor from the location' do
        expect do
          delete :destroy, format: 'json', id: @location.instructors.first.id, location_id: @location.id
        end.to change{ Location.find(@location.id).instructors.count }.by(-1)
      end
      it 'does not delete the instructor' do
        expect do
          delete :destroy, format: 'json', id: @location.instructors.first.id, location_id: @location.id
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
            post :create, format: 'json', id: instructor.id, location_id: location.id
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
            post :create, { format: 'json', location_id: location.id }.merge(instructor_params)
            User.last.attributes.symbolize_keys.slice(*instructor_params[:user].keys).should eq instructor_params[:user]
          end.to change{ Location.find(location.id).instructors.count }.by(1)
        end
      end
    end
  end
end

