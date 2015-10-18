class DirectorySegmentsController < ApplicationController
  decorates_assigned :segment
  decorates_assigned :segments

  before_action :set_segment, only: [:show]

  helper_method :map

  def index
    @segments = DirectorySegment.parent_segments

    tracker.track('showDirectorySegmentsIndex',
      tl_segment_count: @segments.count
    )

    respond_to do |format|
      format.html
      format.json { render json: segments }
    end
  end

  def show
    tracker.track('showDirectorySegment',
      segment: @segment.name,
      parent: @segment.parent_segment.try(:name),
      synthetic: @segment.synthetic
    )

    respond_to do |format|
      format.html
      format.json { render json: segment }
    end
  end

  private

  def set_segment
    @segment = DirectorySegment.for(params.slice(:country, :city))

    head :not_found and return false unless @segment.present?
  end

  def map
    @_map ||= Map.new(
      center: segment.to_coordinates,
      zoom: segment.zoom,
      minZoom: Map::DEFAULT_MIN_ZOOM,
      geolocate: 0,
      locations: segment.locations,
      refresh: 0
    )
  end
end
