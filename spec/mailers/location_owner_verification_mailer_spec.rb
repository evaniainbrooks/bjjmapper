require "spec_helper"

describe LocationOwnerVerificationMailer do
  describe '#feedback_email' do
    let(:email) { 'testemail' }
    let(:url) { 'someurl' }
    let(:verification_context) { build(:location_owner_verification, email: email) }
    let(:mail) { LocationOwnerVerificationMailer.verification_email(verification_context, url) }

    it 'renders the subject' do
      mail.subject.should eq 'BJJMapper.com Academy Owner Verification'
    end

    it 'renders the receiver email' do
      mail.to.should eq [email]
    end

    it 'renders the sender email' do
      mail.from.should eq [LocationOwnerVerificationMailer::DEFAULT_FROM]
    end

    it 'renders the message' do
      mail.body.encoded.should match(url)
    end
  end
end

