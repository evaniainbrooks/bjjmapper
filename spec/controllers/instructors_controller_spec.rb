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
      it 'adds the instructor to the location' do
        expect {
          post :create, { format: 'json', id: instructor.id, location_id: location.id }
        }.to change{ Location.find(location.id).instructors.count }.by(1)
      end
    end
  end
end

