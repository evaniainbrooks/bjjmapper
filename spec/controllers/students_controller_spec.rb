require 'rails_helper'
require 'shared/tracker_context'

describe StudentsController do
  include_context 'skip tracking'
  let(:anonymous_user) { create(:user, role: 'anonymous') }
  let(:session_params) { { :user_id => anonymous_user.to_param } }
  describe 'DELETE destroy' do
    context 'with json format' do
      before { @instructor = create(:instructor_with_students) }
      it 'removes the student from the instructor' do
        anonymous_user
        expect do
          delete :destroy, { format: 'json', id: @instructor.lineal_children.first.id, user_id: @instructor.id }, session_params
        end.to change{ User.find(@instructor.id).lineal_children.count }.by(-1)
      end
      it 'does not delete the student' do
        anonymous_user
        expect do
          delete :destroy, { format: 'json', id: @instructor.lineal_children.first.id, user_id: @instructor.id }, session_params
        end.to change{ User.count }.by(0)
      end
    end
  end
  describe 'POST create' do
    let(:student) { create(:user) }
    let(:instructor) { create(:user) }
    context 'with json format' do
      context 'with a simple id' do
        it 'adds the student to the instructor' do
          expect do
            post :create, { format: 'json', id: student.id, user_id: instructor.id }, session_params
          end.to change{ User.find(instructor.id).lineal_children.count }.by(1)
        end
      end
      context 'with a user object' do
        let(:student_params) do
          {
            :user => {
              :name => 'Test Instructor',
              :email => 'test1@bjjmapper.com',
              :belt_rank => 'brown',
              :stripe_rank => 1
            }
          }
        end
        it 'creates the student and adds them to the instructor' do
          expect do
            post :create, { format: 'json', user_id: instructor.id }.merge(student_params), session_params
            #User.last.attributes.symbolize_keys.slice(*student_params[:user].keys).should eq student_params[:user]
          end.to change{ User.find(instructor.id).lineal_children.count }.by(1)
        end
      end
    end
  end

  describe 'GET index' do
    context 'with json format' do
      let(:instructor) { build(:user) }
      before { User.stub(:find).and_return(instructor) }
      context 'when there are students' do
        let(:students) { build_list(:user, 3) }
        before { User.any_instance.stub(:lineal_children).and_return(students) }
        it 'returns the students' do
          get :index, format: 'json', user_id: '123'
          assigns[:students].count.should eq students.count
        end
      end
      context 'when there are no students' do
        before { User.any_instance.stub(:lineal_children).and_return([]) }
        it 'returns 204 no content' do
          get :index, format: 'json', user_id: '123'
          response.status.should eq 204
        end
      end
    end
  end
end

