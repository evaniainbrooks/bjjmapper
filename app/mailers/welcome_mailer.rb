class WelcomeMailer < ActionMailer::Base
  DEFAULT_FROM = "info@bjjmapper.com"

  default from: DEFAULT_FROM

  def welcome_email(user, urls)
    @urls = urls
    @user = user

    mail(to: @user.email, subject: 'Welcome to BJJMapper.com')
  end
end
