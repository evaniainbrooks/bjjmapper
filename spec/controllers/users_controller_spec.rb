require 'spec_helper'
require 'shared/tracker_context'

describe UsersController do
  include_context 'skip tracking'
  describe 'GET reviews' do
    context 'with json format' do
      let(:user) { create(:user) }
      let(:location) { create(:location) }
      before { create(:review, user: user, location: location) }
      it 'returns the recent reviews' do
        get :reviews, id: user.id, format: 'json', count: 1
        response.should be_success
        response.body.should match(user.reviews.first.decorate.to_json)
      end
    end
  end
  describe 'GET index' do
    context 'with html format' do
      let(:invisible_bb) { create(:user, flag_display_directory: false, belt_rank: 'black') }
      let(:bb) { create(:user, belt_rank: 'black') }
      let(:pb) { create(:user, belt_rank: 'purple') }
      before { invisible_bb; bb; pb }
      it 'returns the grouped users' do
        get :index, { format: 'html' }
        response.should be_ok
        assigns[:users]['black'].should include(bb)
        assigns[:users]['black'].should_not include(invisible_bb)
        assigns[:users]['purple'].should include(pb)
      end
    end
  end
  describe 'GET show' do
    let(:user) { build(:user) }
    before { User.stub(:find).and_return(user) }
    context 'with json format' do
      it 'returns the user' do
        get :show, id: '1234', format: 'json'
        response.body.should eq user.to_json
      end
    end
    context 'with html format' do
      context 'when the redirect_to_user field is blank' do
        it 'renders the show page' do
          get :show, id: '1234', format: 'html'
          response.should render_template('users/show')
        end
      end
      context 'when the redirect_to_user field is set' do
        let(:other_user) { create(:user) }
        before { user.stub(:redirect_to_user).and_return(other_user) }
        it 'redirects to the other user' do
          get :show, id: '1234', format: 'html'
          response.should redirect_to(user_path(other_user))
        end
      end
    end
  end
  describe 'POST create' do
    let(:user) { create(:user, role: 'user') }
    let(:session_params) { { :user_id => user.to_param } }
    let(:create_params) { { :user => { :name => 'Buddy', :email => 'buddy@hotmale.com', :belt_rank => 'purple', :stripe_rank => 3 } } }
    context 'with html format' do
      it 'creates and redirects to a new user in edit mode' do
        user
        expect do
          post :create, create_params.merge({:format => 'html'}), session_params
          response.should redirect_to(user_path(assigns(:user), edit: 1, create: 1))
        end.to change { User.count }.by(1)
      end
    end
    context 'with json format' do
      it 'creates and returns a new user' do
        post :create, create_params.merge({:format => 'json'}), session_params
        response.body.should match(create_params[:user][:name])
      end
    end
  end
  describe 'POST update' do
    let(:user) { create(:user, role: 'user') }
    let(:session_params) { { :user_id => user.to_param } }
    let(:new_user) { create(:user, name: 'Buddy') }
    let(:update_params) { { :user => { :name => 'Buddy Holly' } } }
    context 'when the user is not editable' do
      before { User.any_instance.stub(:editable_by?).and_return(false) }
      it 'returns forbidden' do
        post :update, { id: new_user.id }.merge(update_params), session_params
        response.status.should eq 403
      end
    end
    context 'with json format' do
      before { User.any_instance.stub(:editable_by?).and_return(true) }
      it 'updates and returns the user' do
        post :update, { id: user.id, :format => 'json' }.merge(update_params), session_params
        response.body.should match update_params[:user][:name]
      end
    end
    context 'with html format' do
      before { User.any_instance.stub(:editable_by?).and_return(true) }
      it 'redirects back to the user' do
        post :update, { id: user.id, :format => 'html' }.merge(update_params), session_params
        response.body.should redirect_to(user_path(user, edit: 0))
      end
    end
  end
  describe 'POST remove_image' do
    let(:user) { create(:user, image_tiny: 'evan', image: 'xyz', image_large: 'abc') }
    context 'when not signed in' do
      it 'returns not_authorized' do
        post :remove_image, { id: user.to_param, :format => 'json' }
        response.status.should eq 401
      end
    end
    context 'when locked and no permissions' do
      let(:session_params) { { user_id: create(:user, role: 'user').to_param } }
      let(:locked_user) { create(:user, provider: '1234', flag_locked: true, image_tiny: 'evan', image: 'xyz', image_large: 'abc') }
      context 'with json format' do
        it 'returns forbidden' do
          post :remove_image, { id: locked_user.to_param, :format => 'json' }, session_params
          response.status.should eq 403
        end
      end
    end
    context 'when signed in' do
      let(:session_params) { { user_id: create(:user).to_param } }
      context 'with json format' do
        it 'clears the images and returns the location' do
          post :remove_image, { id: user.to_param, :format => 'json' }, session_params
          assigns[:user].image.should eq nil
          assigns[:user].image_large.should eq nil
          assigns[:user].image_tiny.should eq nil
        end
      end
    end
  end
end

