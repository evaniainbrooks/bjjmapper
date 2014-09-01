class FeedbackMailer < ActionMailer::Base
  DEFAULT_TO = "evaniainbrooks@gmail.com"
  
  default from: "no-reply@rollfindr.com"
  default to: DEFAULT_TO

  def feedback_email(from, email, message, user = nil)
    @user = user
    @email = email
    @message = message + " ||user is #{from} (#{user.try(:id)})"
    mail(from: @email, to: DEFAULT_TO, subject: 'Feedback from Website', content_type: 'text/html', body: @message)
  end
end
