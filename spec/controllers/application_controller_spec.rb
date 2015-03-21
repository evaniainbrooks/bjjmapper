require 'spec_helper'
require 'shared/tracker_context'

describe ApplicationController do
  include_context 'skip tracking'
  describe '.current_user' do
    context 'when there is no session user' do
      it 'returns a new anonymous user' do
        expect do
          get :meta, {}, {}
          controller.send(:current_user).should be_anonymous
          controller.send(:signed_in?).should be_falsey
        end.to change { User.count }.by(1)
      end
    end
    context 'when there is a session user' do
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
  describe 'GET geocode' do
    context 'with json format' do
      context 'when the geocoder service returns results' do
        let(:location) { { 'lat' => 80.0, 'lng' => 80.0 } }
        before do
          search_result = double('search result', city: '', address: '', street_address: '', state: '', postal_code: '', country: '')
          search_result.stub('geometry') { { 'location' => location } }
          search_result.stub('coordinates') { [location['lat'], location['lng']] }
          Geocoder.stub('search') { [search_result, search_result] }
        end
        it 'returns the location of the first search result' do
          get :geocode, query: 'test', format: 'json'
          response.should be_ok
        end
      end
      context 'when the geocoder service returns nothing' do
        before { Geocoder.stub(:search) { [] } }
        it 'returns 404' do
          get :geocode, query: 'test', format: 'json'
          response.status.should eq 404
        end
      end
    end
  end
  describe 'GET map' do
    it 'renders the map' do
      get :map
      response.should render_template('application/map')
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
