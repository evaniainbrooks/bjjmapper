class DirectorySegmentsController < ApplicationController
  decorates_assigned :directory_segment
  decorates_assigned :directory_segments

  before_action :set_segment, only: [:show]

  helper_method :map

  def index
    @directory_segments = DirectorySegment.parent_segments

    tracker.track('showDirectorySegmentsIndex',
      tl_segment_count: @directory_segments.count
    )

    respond_to do |format|
      format.html
      format.json { render json: segments }
    end
  end

  def show
    tracker.track('showDirectorySegment',
      segment: @directory_segment.name,
      parent: @directory_segment.parent_segment.try(:name),
      synthetic: @directory_segment.synthetic
    )

    respond_to do |format|
      format.html
      format.json { render partial: 'directory_segment' }
    end
  end

  private

  def set_segment
    @directory_segment = DirectorySegment.for(params.slice(:country, :city))

    head :not_found and return false unless @directory_segment.present?
  end

  def map
    @_map ||= Map.new(
      lat: directory_segment.lat,
      lng: directory_segment.lng,
      zoom: directory_segment.zoom,
      minZoom: Map::DEFAULT_MIN_ZOOM,
      geolocate: 0,
      locations: directory_segment.locations,
      refresh: 0
    )
  end
end
