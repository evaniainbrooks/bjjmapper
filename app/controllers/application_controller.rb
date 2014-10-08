class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :google_maps_api
  helper_method :current_user
  helper_method :signed_in?
  helper_method :correct_user?

  helper_method :action?
  helper_method :all_teams

  def map
    center = params.fetch(:center, [])
    @map = {
      :zoom => center.present? ? Map::ZOOM_LOCATION : Map::ZOOM_DEFAULT,
      :center => center,
      :geolocate => center.blank? ? 1 : 0,
      :locations => [],
      :filters => 1
    }

    respond_to do |format|
      format.html
    end
  end

  def contact
    name = params[:name]
    email = params[:email]
    message = params[:message]

    mail = FeedbackMailer.feedback_email(name, email, message, current_user)
    result = mail.deliver   
    redirect_to meta_path
  end

  def meta
  end
  
  def webstore
    render layout: 'webstore'
  end
  
  private

  def all_teams
    Team.all.limit(50).decorate
  end

  def action?(action)
    params.fetch(:action, :unknown).to_sym.eql?(action)
  end

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end
  end

  def signed_in?
    return true if current_user
  end

  def correct_user?
    @user = User.find(params[:id])
      unless current_user == @user
      redirect_to root_url, :alert => "Access denied."
    end
  end

  def authenticate_user!
    if !current_user
      redirect_to root_url, :alert => 'You need to sign in for access to this page.'
    end
  end

  def google_maps_api
    "#{Rails.configuration.google_maps_endpoint}?key=#{Rails.configuration.google_maps_api_key}&v=3.exp&sensor=false"
  end
end

