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
  protect_from_forgery with: :null_session
  helper_method :google_maps_api
  helper_method :current_user
  helper_method :signed_in?
  helper_method :correct_user?

  helper_method :action?
  helper_method :controller?

  helper_method :ig_client_id

  after_action :log_production_mutative_events

  def homepage
    @map = Map.new(
      zoom: Map::ZOOM_CITY,
      minZoom: Map::DEFAULT_MIN_ZOOM,
      geolocate: 1,
      legend: 0,
      location_type: Location::LOCATION_TYPE_ALL,
      event_type: [Event::EVENT_TYPE_TOURNAMENT],
      locations: [],
      refresh: 0
    )

    @countries = DirectorySegment.parent_segments.asc(:name)
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
    redirect_to meta_path(contacted: 1)
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

  def privacy_policy
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

  def controller?(controller)
    params.fetch(:controller, :unknown).to_sym.eql?(controller)
  end

  def current_user
    return User.where(:role => 'super_user').first if Rails.env.development?

    # NORMAL USER AUTHENTICATION
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
      @current_user ||= anonymous_user

      if @current_user.super_user? && params.key?(:impersonate)
        @current_user = User.find(params[:impersonate])
      end

      @current_user
    rescue Mongoid::Errors::DocumentNotFound
      @current_user ||= anonymous_user
    end
  end

  def anonymous_user
    anon = User.anonymous(request.remote_ip)
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
    "#{ep}?key=#{key}&v=3.exp&libraries=places"
  end

  def ig_client_id
    ENV['INSTAGRAM_CLIENT_ID']
  end

  def log_production_mutative_events
    return if params.fetch(:action, '').eql?('report') || params.fetch(:action, '').eql?('contact')

    if Rails.env.production? && !request.get? && !request.head? && !current_user.internal?
      reason = "Mutative #{request.params[:controller]}/#{request.params[:action]} by #{current_user.try(:name)}"
      description =  "#{request.inspect}"
      subject_url = "#{request.original_url}"

      ReportMailer.report_email(subject_url, reason, description, current_user).deliver
    end
  end

  def redirect_legacy_bsonid_for(object, param, path = nil)
    unless object.slug.try(:blank?)
      redirect_to(path || object, status: :moved_permanently) and return false if /^[a-f0-9]{24}$/ =~ param
    end
  end
end

