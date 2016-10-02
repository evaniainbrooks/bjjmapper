class LocationsController < ApplicationController
  before_action :set_location, only: [:favorite, :schedule, :destroy, :show, :update, :move, :unlock]
  before_action :redirect_legacy_bsonid, only: [:favorite, :schedule, :destroy, :show, :update, :move, :unlock]
  before_action :set_map, only: :show
  before_action :ensure_signed_in, only: [:wizard, :destroy, :create, :update, :move, :unlock]
  before_action :check_permissions, only: [:destroy, :update, :move, :unlock]

  decorates_assigned :location, :locations

  helper_method :created?
  helper_method :reviewed?
  helper_method :error?
  helper_method :deleted?
  helper_method :verified?
  helper_method :closed?
  helper_method :moved?

  RECENT_COUNT_DEFAULT = 5
  RECENT_COUNT_MAX = 10

  NEARBY_DISTANCE_DEFAULT = 5
  NEARBY_COUNT_DEFAULT = 4

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

    @locations = Location.academies.desc('created_at').limit(count)

    respond_to do |format|
      format.json 
    end
  end

  def schedule
    tracker.track('showSchedule',
      id: @location.to_param
    )

    respond_to do |format|
      format.html
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

    lat = params.fetch(:lat, nil).try(:to_f)
    lng = params.fetch(:lng, nil).try(:to_f)
    reject = params.fetch(:reject, nil)

    fetch_count = count + (reject.present? ? 1 : 0)

    head :bad_request and return false unless lat.present? && lng.present?

    @locations = Location.near([lat, lng], distance).limit(fetch_count).to_a
    @locations.reject!{|loc| loc.to_param.eql?(reject)} if reject.present?

    head :no_content and return false unless @locations.present?

    @locations = decorated_locations_with_distance_to_center(@locations, lat, lng)

    respond_to do |format|
      format.json { render status: :ok, partial: 'location', collection: @locations }
    end
  end

  def destroy
    tracker.track('deleteLocation',
      id: @location.to_param,
      location: @location.as_json({})
    )

    @location.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render status: :ok, partial: 'location' }
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
      location: @location.as_json({})
    )

    respond_to do |format|
      format.json { render partial: 'location' }
      format.html { redirect_to location_path(location, edit: 1, create: 1) }
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
      location: @location.as_json({}),
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

  def set_map
    @map = Map.new(
      :zoom => Map::ZOOM_LOCATION,
      :minZoom => Map::ZOOM_CITY,
      :lat => @location.lat,
      :lng => @location.lng,
      :location_type => Location::LOCATION_TYPE_ALL, 
      :geolocate => 0,
      :locations => [],
      :refresh => 0
    )
  end

  def create_params
    p = params.require(:location).permit(
      :ig_hashtag,
      :city,
      :street,
      :postal_code,
      :state,
      :country,
      :title,
      :description,
      :coordinates,
      :team_id,
      :directions,
      :phone,
      :email,
      :website,
      :facebook,
      :twitter,
      :instagram)

    p[:coordinates] = JSON.parse(p[:coordinates]) if p[:coordinates].present?
    p[:modifier] = current_user if signed_in?
    p
  end

  def redirect_legacy_bsonid
    redirect_to(@location, status: :moved_permanently) and return false if /^[a-f0-9]{24}$/ =~ params[:id]
  end

  def set_location
    id_param = params.fetch(:id, '')
    @location = Location.academies.find(id_param)

    head :not_found and return false unless @location.present?
  end

  def check_permissions
    head :forbidden and return false unless current_user.can_edit?(@location)
  end
end
