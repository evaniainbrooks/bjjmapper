class ParoscampMailer < ActionMailer::Base
  #DEFAULT_TO = "nickbjjman@gmail.com"
  DEFAULT_TO = "info@bjjmapper.com"
  DEFAULT_FROM = "no-reply@bjjmapper.com"

  default from: DEFAULT_FROM
  default to: DEFAULT_TO

  def feedback_email(name, email, phone, message)
    @email = email
    @message = {
      :name => name,
      :email => email,
      :phone => phone,
      :message => message
    }
    mail(from: DEFAULT_FROM, to: DEFAULT_TO, subject: 'Feedback from Website', content_type: 'text/html', body: @message)
  end
end
