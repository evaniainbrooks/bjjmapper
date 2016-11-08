require 'spec_helper'
require 'shared/tracker_context'

describe ApplicationController do
  include_context 'skip tracking'
  describe '.current_user' do
    context 'with api_key param' do
      let(:api_key) { 'some-key-123' }
      let(:user) { build(:user) }
      context 'and key is valid' do
        before do
          User.stub(:where, :first).and_return(user)
        end
        xit 'returns the api user' do
          get :meta, { api_key: api_key }, {}
          controller.send(:current_user).should eq user
        end
      end
      context 'and key is invalid' do
        before { User.stub(:find).and_return(nil) }
        it 'returns 403 forbidden' do
          get :meta, { api_key: api_key }, {}
          controller.send(:current_user).should be_falsey
        end
      end
    end
    
    context 'when there is no session user' do
      it 'returns a new anonymous user' do
        expect do
          get :meta, {}, {}
          controller.send(:current_user).should be_anonymous
          controller.send(:signed_in?).should be_falsey
        end.to change { User.count }.by(1)
      end
    end
    context 'when the session user cannot be found' do
      it 'returns an anonymous user' do
        expect do
          get :meta, {}, { user_id: 'notauser' }
          controller.send(:current_user).should be_anonymous
        end.to change { User.count }.by(1)
      end
    end
    context 'when there is a session user' do
      context 'with super_user and impersonate param' do
        let(:user) { create(:user, role: 'super_user') }
        let(:impersonated_user) { create(:user) }
        it 'returns the impersonated user' do
          get :meta, { impersonate: impersonated_user.to_param }, { user_id: user.to_param }
          controller.send(:current_user).should eq impersonated_user
        end
      end
      context 'without impersonate param' do
        let(:user) { create(:user) }
        it 'returns the session user' do
          expect do
            get :meta, {}, { user_id: user.to_param }
            controller.send(:current_user).should eq user
            controller.send(:signed_in?).should be_truthy
          end.to change { User.count }.by(1)
        end
      end
    end
  end
  describe 'GET homepage' do
    it 'renders the homepage' do
      get :homepage
      response.should render_template('application/homepage')
    end
  end
  describe 'GET meta' do
    it 'renders the content' do
      get :meta
      response.should render_template('application/meta')
    end
  end

  describe 'POST contact' do
    before do
      mailer = double
      mailer.should_receive(:deliver)
      FeedbackMailer.should_receive(:feedback_email).and_return(mailer)
    end
    it 'mails the message' do
      post :contact, name: 'bob', email: 'job@bbbj.com', message: 'whoahwhoah'
      response.should redirect_to(meta_path(contacted: 1))
    end
  end
  describe 'POST report' do
    before do
      mailer = double
      mailer.should_receive(:deliver)
      ReportMailer.should_receive(:report_email).and_return(mailer)
    end
    context 'with json format' do
      it 'mails the report' do
        post :report, format: 'json', reason: 'boo', description: 'test'
        response.should be_ok
      end
    end
  end
end
