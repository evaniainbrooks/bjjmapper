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
      mailer = double
      mailer.should_receive(:deliver)
      FeedbackMailer.should_receive(:feedback_email).and_return(mailer)
    end
    it 'mails the message' do
      pending 'fixme'
      post :meta, { :name => 'bob', :email => 'job@bbbj.com', :message => 'whoahwhoah' }
      response.should redirect_to(meta_path)
    end
  end
end
