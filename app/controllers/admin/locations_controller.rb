class Admin::LocationsController < Admin::AdminController
  def show
    location_id = params.fetch(:id, '')
    @location = Location.find(location_id)
  end

  def fetch
    location_id = params.fetch(:id, '')
    @location = Location.find(location_id)
    @location.search_metadata!
    head :no_content
  end

  def listings
    location_id = params.fetch(:id, '')
    @location = Location.find(location_id)
    scope = params.fetch(:scope, nil)
    @response = RollFindr::LocationFetchService.listings(location_id, scope: scope, lat: @location.lat, lng: @location.lng)
  end

  def associate
    location_id = params.fetch(:id, '')
    scope = params.fetch(:scope, nil)
    remote_id = params.fetch(:remote_id, nil)

    opts = { scope: scope }
    opts["#{scope.downcase}_id".to_sym] = remote_id
    RollFindr::LocationFetchService.associate(location_id, opts)

    head :no_content
  end

  def index
    @locations = Location.limit(100).sort({created_at:-1})
  end

  def pending
    order = params.fetch(:order, 1).to_i
    @locations = Location.limit(100).pending.sort({status_updated_at: order})
  end

  def rejected
    @locations = Location.limit(100).rejected.sort({created_at:-1})
  end

  def moderate
    order = params.fetch(:order, 1).to_i
    redirect_to location_path(Location.pending.sort({status_updated_at: order}).first, moderate: 1)
  end
end
