require 'analyzable'
require 'analyzable_user_super_properties'
require 'analyzable_robot_properties'

class ApplicationController < ActionController::Base
  include RollFindr::Analyzable
  include RollFindr::AnalyzableUserSuperProperties
  include RollFindr::AnalyzableRobotProperties
  include TeamsHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :google_maps_api
  helper_method :current_user
  helper_method :signed_in?
  helper_method :correct_user?

  helper_method :action?

  def geocode
    search_query = params.fetch(:query, '')
    search_result = Geocoder.search(search_query)

    tracker.track('geocodeQuery',
      query: search_query,
      resultCount: search_result.count
    )

    respond_to do |format|
      format.json do
        if search_result.count > 0
          render json: search_result[0].geometry['location']
        else
          render status: :not_found, json: {}
        end
      end
    end
  end

  def map
    center = params.fetch(:center, [])
    geolocate = center.present? ? 0 : 1
    zoom = params.fetch(:zoom, nil).try(:to_i)
    zoom ||= center.present? ? Map::ZOOM_LOCATION : Map::ZOOM_DEFAULT
    @map = {
      zoom: zoom,
      center: center,
      geolocate: geolocate,
      locations: [],
      refresh: 1
    }

    tracker.track('showMap',
      zoom: zoom,
      center: center,
      geolocate: geolocate
    )

    respond_to do |format|
      format.html { render layout: 'map' }
    end
  end

  def contact
    name = params[:name]
    email = params[:email]
    message = params[:message]

    tracker.track('metaSendMessage',
      name: name,
      email: email,
      message: message
    )

    FeedbackMailer.feedback_email(name, email, message, current_user).deliver
    redirect_to meta_path
  end

  def report
    reason = params.fetch(:reason, nil)
    description = params.fetch(:description, nil)
    subject_url = request.referer

    tracker.track('metaSendReport',
      reason: reason,
      description: description,
      subject_url: request.referer
    )

    render :bad_request and return false unless reason.present?

    ReportMailer.report_email(subject_url, reason, description, current_user).deliver
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render status: :ok, json: {} }
    end
  end

  def meta

  end

  protected

  def ensure_signed_in
    respond_to do |format|
      format.html { redirect_to '/signin' }
      format.json { render status: :unauthorized,  json: {} }
    end unless signed_in?
  end

  private

  def action?(action)
    params.fetch(:action, :unknown).to_sym.eql?(action)
  end

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
      @current_user ||= anonymous_user
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end
  end

  def anonymous_user
    anon = User.create_anonymous(request.remote_ip)
    session[:user_id] = anon.to_param
    anon
  end

  def signed_in?
    return true if current_user && !current_user.anonymous?
  end

  def correct_user?
    @user = User.find(params[:id])
    unless current_user == @user
      redirect_to root_url, :alert => 'Access denied.'
    end
  end

  def google_maps_api
    ep = Rails.configuration.google_maps_endpoint
    key = Rails.configuration.google_maps_api_key
    "#{ep}?key=#{key}&v=3.exp&sensor=false"
  end
end

