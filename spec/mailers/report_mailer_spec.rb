require "spec_helper"

describe ReportMailer do
  describe '#report_email' do
    let(:subject) { '12345' }
    let(:reason) { 'reason' }
    let(:description) { 'description' }
    let(:user) { build(:user, id: '9438', role: 'anonymous') }
    let(:email) { 'test@gmail.com' }
    let(:mail) { ReportMailer.report_email(email: email, subject: subject, reason: reason, description: description, user: user) }
    it 'renders the subject' do
      expect(mail.subject).to match("#{reason} report from #{email}")
    end
    it 'renders the receiver email' do
      expect(mail.to).to eql([ReportMailer::DEFAULT_TO])
    end
    it 'renders the sender email' do
      expect(mail.from).to eql([ReportMailer::DEFAULT_FROM])
    end
    it 'renders the message' do
      expect(mail.body.encoded).to match(user.id)
      expect(mail.body.encoded).to match(subject)
      expect(mail.body.encoded).to match(description)
    end
  end
end


