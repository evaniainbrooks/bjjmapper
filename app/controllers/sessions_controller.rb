class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    user = User.from_omniauth(auth_info, request.remote_ip)
    if user.new_record?
      user.save
      session[:user_id] = user.id
      redirect_to user_path(user, edit: 1)
    else
      user.update_attribute(:last_seen_at, Time.now)
      session[:user_id] = user.id
      redirect_to root_url, notice: 'Signed in!'
    end
  end

  def new
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'Signed Out'
  end

  private

  def auth_info
    request.env['omniauth.auth']
  end
end
