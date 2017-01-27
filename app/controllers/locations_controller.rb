class LocationsController < ApplicationController
  include LocationsHelper

  before_action :set_location, only: [:favorite, :schedule, :destroy, :show, :update, :move, :unlock, :close, :remove_image]
  before_action :redirect_legacy_bsonid, only: [:schedule, :show]
  before_action :set_map, only: :show
  before_action :ensure_signed_in, only: [:wizard, :destroy, :create, :update, :move, :unlock, :close, :remove_image]
  before_action :check_permissions, only: [:destroy, :update, :move, :unlock, :close, :remove_image]

  decorates_assigned :location, :locations, :with => LocationFetchServiceDecorator

  helper_method :created?
  helper_method :reviewed?
  helper_method :error?
  helper_method :deleted?
  helper_method :verified?
  helper_method :closed?
  helper_method :moved?

  RECENT_COUNT_DEFAULT = 6
  RECENT_COUNT_MAX = 10

  NEARBY_DISTANCE_DEFAULT = 200
  NEARBY_COUNT_DEFAULT = 4

  def close
    reopen = params.fetch(:reopen, 0).to_i.eql?(1)
    
    tracker.track('closeLocation',
      location: @location.to_param,
      reopen: reopen
    )

    @location.update_attribute(:flag_closed, !reopen)

    respond_to do |format|
      format.html { redirect_to location_path(@location) }
      format.json { render partial: 'location' }
    end
  end

  def unlock
    tracker.track('unlockLocation',
      location: @location.to_param
    )

    @location.update_attribute(:owner_id, nil)

    respond_to do |format|
      format.html { redirect_to location_path(@location) }
      format.json { render partial: 'location' }
    end
  end

  def recent
    count = [params.fetch(:count, RECENT_COUNT_DEFAULT).to_i, RECENT_COUNT_MAX].min

    tracker.track('showRecentLocations',
      count: count
    )

    @locations = RollFindr::Redis.cache(expire: 1.hour.seconds, key: recent_cache_key(count)) do
      Location.academies.verified.desc('created_at').limit(count).to_a
    end

    respond_to do |format|
      format.json 
    end
  end

  def schedule
    @starting = params.fetch(:starting, nil)
    
    tracker.track('showSchedule',
      id: @location.to_param
    )

    respond_to do |format|
      format.html
    end
  end

  def random
    scope = current_user_location_scope.academies.not_rejected
    @location = scope.skip(rand(scope.count)).first

    tracker.track('showRandomLocation',
      id: @location.to_param
    )

    respond_to do |format|
      format.html { redirect_to @location, random: 1 }
      format.json { render partial: 'location' }
    end
  end

  def show
    tracker.track('showLocation',
      id: @location.to_param
    )

    respond_to do |format|
      format.html
      format.json { render partial: 'location' }
    end
  end

  def nearby
    distance = params.fetch(:distance, NEARBY_DISTANCE_DEFAULT).to_i
    count = params.fetch(:count, NEARBY_COUNT_DEFAULT).to_i
    location_filter = params.fetch(:location_type, [Location::LOCATION_TYPE_ACADEMY]).collect(&:to_i)

    lat = params.fetch(:lat, nil).try(:to_f)
    lng = params.fetch(:lng, nil).try(:to_f)
    reject = params.fetch(:reject, nil)

    fetch_count = count + (reject.present? ? 1 : 0)

    head :bad_request and return false unless lat.present? && lng.present?

    @locations = Location.near([lat, lng], distance).where(:loctype.in => location_filter).not_closed.verified.limit(fetch_count).to_a
    @locations.reject!{|loc| loc.to_param.eql?(reject)} if reject.present?

    head :no_content and return false unless @locations.present?

    @locations = decorated_locations_with_distance_to_center(@locations, lat, lng)

    respond_to do |format|
      format.json
    end
  end

  def destroy
    tracker.track('deleteLocation',
      id: @location.to_param,
      location: @location.attributes.as_json({})
    )

    @location.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render status: :ok, partial: 'location' }
    end
  end
  
  def remove_image
    tracker.track('removeLocationImage',
      id: @location.to_param,
      image: @location.image
    )

    @location.update!({
      :image => nil,
      :image_large => nil,
      :image_tiny => nil
    })

    respond_to do |format|
      format.json { render partial: 'locations/location' }
    end
  end

  def wizard
    tracker.track('showLocationWizard')
    respond_to do |format|
      format.html 
    end
  end

  def create
    @location = Location.create(create_params)

    tracker.track('createLocation',
      location: @location.attributes.as_json({})
    )

    RollFindr::Redis.del(recent_cache_key(RECENT_COUNT_DEFAULT))

    respond_to do |format|
      format.json
      format.html { redirect_to location_path(@location, create: 1, edit: 1) }
    end
  end

  def move
    lat = params.fetch(:lat, nil).try(:to_f)
    lng = params.fetch(:lng, nil).try(:to_f)

    head :bad_request and return false unless lat.present? && lng.present?

    tracker.track('moveLocation',
      id: @location.to_param,
      old_coords: @location.to_coordinates,
      new_coords: [lat, lng])

    @location.update!({
      coordinates: [lng, lat],
      street: nil,
      city: nil,
      state: nil,
      country: nil,
      postal_code: nil
    })

    respond_to do |format|
      format.json { render partial: 'location' }
      format.html { render json: location_path(@location, success: 1) }
    end
  end

  def update
    tracker.track('updateLocation',
      id: @location.to_param,
      location: @location.attributes.as_json({}),
      updates: create_params
    )

    @location.update!(create_params)

    respond_to do |format|
      format.json { render partial: 'location' }
      format.html { redirect_to location_path(location, success: 1, edit: 0) }
    end
  end

  def favorite
    delete = params.fetch(:delete, 0).to_i.eql?(1)

    tracker.track('favoriteLocation',
      delete: delete,
      id: @location.to_param,
      user_id: current_user.to_param
    )

    unless delete
      current_user.favorite_locations << @location
    else
      current_user.favorite_locations.delete(@location)
    end

    respond_to do |format|
      format.json { render partial: 'location' }
    end
  end

  private

  def decorated_locations_with_distance_to_center(locations, lat, lng)
    LocationDecorator.decorate_collection(locations, context: { lat: lat, lng: lng })
  end
  
  private

  def moved?
    location.flag_closed? && location.moved_to_location.present?
  end

  def closed?
    location.flag_closed? && location.moved_to_location.blank?
  end

  def verified?
    params.fetch(:verified, 0).to_i.eql?(1)
  end

  def deleted?
    params.fetch(:deleted, 0).to_i.eql?(1)
  end

  def created?
    return params.fetch(:create, 0).to_i.eql?(1)
  end
  
  def reviewed?
    return params.fetch(:reviewed, 0).to_i.eql?(1)
  end
  
  def error?
    return params.fetch(:error, 0).to_i.eql?(1)
  end

  def recent_cache_key(count)
    cache_key = ['Recent', count].compact.collect(&:to_s).join('-')
  end

  def set_map
    @map = Map.new(
      :zoom => Map::ZOOM_LOCATION,
      :minZoom => Map::ZOOM_CITY,
      :lat => @location.lat,
      :lng => @location.lng,
      :location_type => Location::LOCATION_TYPE_ALL, 
      :geolocate => 0,
      :locations => [location],
      :refresh => 0
    )
  end

  def create_params
    location_create_params
  end

  def redirect_legacy_bsonid
    redirect_legacy_bsonid_for(@location, params[:id])
  end

  def set_location
    id_param = params.fetch(:id, '')
    @location = if action?(:schedule) || current_user.super_user?
      current_user_location_scope
    else
      current_user_location_scope.academies
    end.find(id_param)

    head :not_found and return false unless @location.present?
  end

  def check_permissions
    head :forbidden and return false unless current_user.can_edit?(@location)
  end

  def current_user_location_scope
    if current_user.preference(:pending)
      Location
    else
      Location.verified
    end
  end
end
