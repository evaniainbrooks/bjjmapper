class LocationOwnerVerificationMailer < ActionMailer::Base
  DEFAULT_FROM = "verify@bjjmapper.com"

  default from: DEFAULT_FROM

  def verification_email(verification, url)
    @url = url
    @to = verification.email
    @user = verification.user
    @location = verification.location

    mail(to: @to, subject: 'BJJMapper.com Academy Owner Verification')  
  end
end
