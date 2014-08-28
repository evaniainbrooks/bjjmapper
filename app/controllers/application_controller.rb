class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :google_maps_api
  helper_method :current_user
  helper_method :signed_in?
  helper_method :correct_user?

  def search
    searchables = if term_query?
      Location.all.to_a
    else
      viewport_query
    end
      
    respond_to do |format|
      format.json { render json: searchables }
    end
  end

  def show
  end

  def webstore
    render layout: 'webstore'
  end

  private

  def viewport_query
    # TODO Distance value
    center = params[:center]
    locations = Location.near(center, 25)
  end

  def term_query?
    params[:q].present?
  end

  private

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

