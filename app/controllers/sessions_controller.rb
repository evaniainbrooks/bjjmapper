class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    user = User.from_omniauth(auth_info, request.remote_ip)

    tracker.track('createSession',
      user: user.to_param,
      ip_address: request.remote_ip,
      created_user: user.new_record?,
      provider: auth_info['provider']
    )

    if user.new_record?
      user.save
      tracker.alias(user.to_param, session[:user_id])
      session[:user_id] = user.to_param

      send_welcome_email(user)

      redirect_to user_path(user, edit: 1, welcome: 1)
    else
      user.update_attribute(:last_seen_at, Time.now)
      tracker.alias(user.to_param, session[:user_id])
      session[:user_id] = user.to_param
      redirect_to root_url, notice: 'Signed in!'
    end
  end

  def new
    tracker.track('showRegister',
      ip_address: request.remote_ip,
      provider: auth_info.try(:[], 'provider')
    )
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
  end

  def destroy
    tracker.track('deleteSession')
    reset_session
    redirect_to root_url, notice: 'Signed Out'
  end

  private

  def send_welcome_email(user)
    urls = {
      profile: user_url(user, edit: 1, welcome: 1, ref: 'welcome_email'),
      home: root_url(ref: 'welcome_email'),
      map: map_url(ref: 'welcome_email'),
      create: wizard_locations_url(ref: 'welcome_email')
    }

    WelcomeMailer.welcome_email(user, urls).deliver
  end

  def auth_info
    request.env['omniauth.auth']
  end
end
