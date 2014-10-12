require 'spec_helper'

describe ApplicationController do
  describe 'GET geocode' do
    context 'with json format' do
      context 'when the geocoder service returns results' do
        let(:location) { { 'lat' => 80.0, 'lng' => 80.0 } }
        before do
          search_result = double('search result')
          search_result.stub('geometry') { { 'location' => location } } 
          Geocoder.stub('search') { [search_result, search_result] }
        end
        it 'returns the location of the first search result' do
          get :geocode, { query: 'test', format: 'json' }
          response.body.should match(location.to_json)
        end
      end
      context 'when the geocoder service returns nothing' do
        before { Geocoder.stub(:search) { [] } }
        it 'returns 404' do
          get :geocode, { query: 'test', format: 'json' }
          response.status.should eq 404
        end
      end
    end
  end
  describe 'GET map' do
    it 'renders the map' do
      get :map
      response.should render_template("application/map")
    end
  end

  describe 'GET meta' do
    it 'renders the content' do
      get :meta
      response.should render_template("application/meta")
    end
  end

  describe 'POST contact' do
    before do
      mailer = double
      mailer.should_receive(:deliver)
      FeedbackMailer.should_receive(:feedback_email).and_return(mailer)
    end
    it 'mails the message' do
      post :contact, { :name => 'bob', :email => 'job@bbbj.com', :message => 'whoahwhoah' }
      response.should redirect_to(meta_path)
    end
  end
end
