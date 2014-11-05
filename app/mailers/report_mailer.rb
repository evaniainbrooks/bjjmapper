class ReportMailer < ActionMailer::Base
  DEFAULT_TO = "evan@bjjmapper.com"
  DEFAULT_FROM = "no-reply@bjjmapper.com"

  default from: DEFAULT_FROM
  default to: DEFAULT_TO

  def report_email(subject, reason, description, user = nil)
    @user = user
    @message = [subject, reason, description, user.try(:id)].join("\r\n")
    mail(from: DEFAULT_FROM, to: DEFAULT_TO, subject: "#{reason} report from website", content_type: 'text/html', body: @message)
  end
end
