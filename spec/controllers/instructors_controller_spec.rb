require 'rails_helper'

describe InstructorsController do
  describe 'DELETE destroy' do
    # TODO: Move this creation logic to factory
    let(:location) { create(:location) }
    let(:instructor) { create(:user) }
    before do
      location.instructors << instructor
    end
    context 'with json format' do 
      it 'removes the instructor from the location' do
        expect {
          delete :destroy, { format: 'json', id: instructor.id, location_id: location.id }
        }.to change{ Location.find(location.id).instructors.count }.by(-1)
      end
      it 'doesnt delete the instructor' do
        expect {
          delete :destroy, { format: 'json', id: instructor.id, location_id: location.id }
        }.to change{ User.count }.by(0)
      end
    end
  end
  describe 'POST create' do
    let(:location) { create(:location) }
    let(:instructor) { create(:user) }
    context 'with json format' do
      context 'with a simple id' do
        it 'adds the instructor to the location' do
          expect {
            post :create, { format: 'json', id: instructor.id, location_id: location.id }
          }.to change{ Location.find(location.id).instructors.count }.by(1)
        end
      end
      context 'with a user object' do
        let(:instructor_params) { { :user => { :name => 'Test Instructor', :email => 'test1@bjjmapper.com', :belt_rank => 'brown', :stripe_rank => 1 } } }
        it 'creates the instructor and adds them to the location' do
          expect {
            post :create, { format: 'json', location_id: location.id }.merge(instructor_params)
            User.last.attributes.symbolize_keys.slice(*instructor_params[:user].keys).should eq instructor_params[:user]
          }.to change{ Location.find(location.id).instructors.count }.by(1)
        end
      end
    end
  end
end

