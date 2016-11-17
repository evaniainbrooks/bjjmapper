class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    user = User.from_omniauth(auth_info, request.remote_ip)

    tracker.track('createSession',
      user: user.to_param,
      ip_address: request.remote_ip,
      created_user: user.new_record?,
      referrer: request.referrer,
      provider: auth_info['provider']
    )

    if user.new_record?
      user.save
      tracker.alias(user.to_param, session[:user_id])
      session[:user_id] = user.to_param

      send_welcome_email(user)

      redirect_to user_path(user, edit: 1, welcome: 1)
    else
      user.last_seen_at = Time.now
      user.ip_address = request.remote_ip
      user.coordinates = nil
      user.geocode
      user.save

      tracker.alias(user.to_param, session[:user_id])
      session[:user_id] = user.to_param

      redirect_to return_url(request.referrer, signed_in: 1)
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
    session[:return_to] = request.referrer
    redirect_url = return_url(request.referrer, signed_out: 1)

    reset_session
    redirect_to redirect_url
  end

  private

  def return_url(return_to, params)
    if return_to
      callback = Addressable::URI.parse(return_to)
      callback.query_values = (callback.query_values || {}).merge(params)

      session.delete(:return_to)
      callback.to_s
    else
      root_url(signed_in: 1)
    end rescue return_to
  end

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
