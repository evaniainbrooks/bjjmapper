require 'spec_helper'

describe WelcomeMailer do
  describe '#welcome_email' do
    let(:email) { 'testemail' }
    let(:urls) { { :profile => 'profile1234', :create => 'create5678', :home => 'home9876', :map => 'map4567' } }
    let(:user) { build(:user, email: email) }
    let(:mail) { WelcomeMailer.welcome_email(user, urls) }

    it 'renders the subject' do
      mail.subject.should eq 'Welcome to BJJMapper.com'
    end

    it 'renders the receiver email' do
      mail.to.should eq [email]
    end

    it 'renders the sender email' do
      mail.from.should eq [WelcomeMailer::DEFAULT_FROM]
    end

    it 'renders the message' do
      mail.body.encoded.should match(urls[:profile])
      mail.body.encoded.should match(urls[:create])
      mail.body.encoded.should match(urls[:map])
    end
  end
end
