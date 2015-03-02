class ParoscampController < ApplicationController 
  skip_before_action :verify_authenticity_token

  def contact
    name = params[:name]
    email = params[:email]
    phone = params[:phone]
    message = params[:message]

    tracker.track('parosMetaSendMessage',
      name: name,
      email: email,
      phone: phone,
      message: message
    )

    ParoscampMailer.feedback_email(name, email, phone, message).deliver
    redirect_to 'http://www.parosbjj.com/camp2015/contact?contacted=1'
  end
end
