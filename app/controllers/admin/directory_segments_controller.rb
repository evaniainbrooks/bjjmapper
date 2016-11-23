class Admin::DirectorySegmentsController < Admin::AdminController
  before_action :set_segment, only: [:edit, :update]

  helper_method :map

  def new
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @directory_segment.update(create_params)

    respond_to do |format|
      format.html do
        if @directory_segment.child?
          redirect_to directory_segment_path(country: @directory_segment.parent_directory_segment.name, city: @directory_segment.name, edit: 1, create: 1) 
        else
          redirect_to directory_segment_path(country: @directory_segment.name, edit: 1, create: 1) 
        end
      end
    end
  end
  def create
    segment = DirectorySegment.create(create_params)

    respond_to do |format|
      format.html do
        if segment.child?
          redirect_to directory_segment_path(country: segment.parent_segment.name, city: segment.name, edit: 1, create: 1) 
        else
          redirect_to directory_segment_path(country: segment.name, edit: 1, create: 1) 
        end
      end
    end
  end

  private

  def create_params
    p = params.require(:directory_segment).permit(
      :distance,
      :zoom,
      :abbreviations,
      :parent_segment_id,
      :name,
      :description,
      :coordinates,
      :flag_index_visible
    )

    p[:abbreviations] = p[:abbreviations].split(',').collect(&:strip)
    p
  end
  
  def set_segment
    @directory_segment = DirectorySegment.find(params[:id])
    @directory_segment ||= DirectorySegment.for(params.slice(:country, :city))

    head :not_found and return false unless @directory_segment.present?
  end

  def map
    @_map ||= Map.new(
      location_type: Location::LOCATION_TYPE_ALL,
      event_type: [Event::EVENT_TYPE_TOURNAMENT, Event::EVENT_TYPE_SEMINAR, Event::EVENT_TYPE_CAMP],
      lat: @directory_segment.lat,
      lng: @directory_segment.lng,
      segment: @directory_segment.id.to_s,
      zoom: @directory_segment.zoom,
      minZoom: 1,
      geolocate: 0,
      refresh: 0
    )
  end
end
