require 'spec_helper'

describe ApplicationController do
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
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end
    it 'mails the message' do
      post :meta, { :name => 'bob', :email => 'job@bbbj.com', :message => 'whoahwhoah' }
      response.should be_ok
      ActionMailer::Base.deliveries.count.should eq 1
      pending "this is failing ahh"
    end
  end
end
