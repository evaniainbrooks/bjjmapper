class FeedbackMailer < ActionMailer::Base
  DEFAULT_TO = "evan@bjjmapper.com"

  default from: "no-reply@bjjmapper.com"
  default to: DEFAULT_TO

  def feedback_email(from, email, message, user = nil)
    @user = user
    @email = email
    @message = message + " ||user is #{from} (#{user.try(:id)})"
    mail(from: @email, to: DEFAULT_TO, subject: 'Feedback from Website', content_type: 'text/html', body: @message)
  end
end
