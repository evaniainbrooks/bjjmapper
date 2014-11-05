require "spec_helper"

describe ReportMailer do
  describe '#report_email' do
    let(:subject) { '12345' }
    let(:reason) { 'reason' }
    let(:description) { 'description' }
    let(:user) { build(:user, id: '9438') }
    let(:mail) { ReportMailer.report_email(subject, reason, description, user) }
    it 'renders the subject' do
      expect(mail.subject).to eql("#{reason} report from website")
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


