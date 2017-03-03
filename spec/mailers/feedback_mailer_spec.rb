require "spec_helper"

describe FeedbackMailer do
  describe '#feedback_email' do
    let(:from_name) { 'Helio Gracie' }
    let(:from_email) { 'helio@gracie.com' }
    let(:message) { 'this is the message' }
    let(:user) { build(:user, id: '123', name: from_name, email: from_email) }
    let(:mail) { FeedbackMailer.feedback_email(from_name, from_email, message, user) }

    it 'renders the subject' do
      expect(mail.subject).to eql('Feedback from Website')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([FeedbackMailer::DEFAULT_TO])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql([from_email])
    end

    it 'renders the message' do
      expect(mail.body.encoded).to match(user.id)
      expect(mail.body.encoded).to match(message)
    end
  end
end


