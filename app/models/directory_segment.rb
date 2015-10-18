require 'mongoid-history'

class DirectorySegment
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Geocoder::Model::Mongoid

  DEFAULT_DISTANCE_MILES = 30

  field :abbreviations, type: Array, default: []
  field :name, type: String
  slug :name, scope: :parent_segment
  validates :name, presence: true
  geocoded_by :full_name
  before_validation :geocode
  before_validation :populate_timezone

  field :synthetic, type: Boolean, default: false
  field :description, type: String
  field :coordinates, type: Array
  validates :coordinates, presence: true

  field :zoom, type: Integer
  field :distance, type: Integer, default: DEFAULT_DISTANCE_MILES
  field :timezone, type: String

  belongs_to :parent_segment, class_name: 'DirectorySegment', inverse_of: :child_segments
  has_many :child_segments, class_name: 'DirectorySegment', inverse_of: :parent_segment

  scope :parent_segments, -> { where(:parent_segment => nil).asc(:name) }
  scope :child_segments, -> { where(:parent_segment.ne => nil).asc(:name) }
  default_scope -> { asc(:name) }

  def self.for(params)
    criteria = params.slice(:city, :country) || {}
    segment = DirectorySegment.find_by(name: params[:country]) || DirectorySegment.synthesize(params.slice(:country), nil)

    if params.key?(:city)
      segment.child_segments.find_by(name: params[:city]) || DirectorySegment.synthesize(params, segment)
    else
      segment
    end
  end

  def editable_by? user
    return true if user.super_user?
    return false
  end

  def full_name
    [self.name, self.parent_segment.try(:name)].compact.join(', ')
  end

  def timezone
    super || (populate_timezone unless self.destroyed?)
  end

  def coordinates=(coordinates)
    self.timezone = nil
    super
  end

  def locations
    if self.child?
      @_locations ||= Location.near(self.to_coordinates, self.distance)
    else
      @_locations ||= Location.where(:country.in => self.abbreviations.push(self.name))
    end
  end

  def to_param
    slug
  end

  def child?
    self.parent_segment.present?
  end

  def parent?
    !self.child_segments.empty?
  end

  def as_json(args = {})
    super(args.merge(except: [:_id, :parent_segment_id, :_slugs])).merge({
      id: self.to_param,
      locations: self.locations,
      parent_segment: self.parent_segment
    })
  end

  private

  def self.synthesize(params, parent_segment = nil)
    distance = params.fetch(:distance, DEFAULT_DISTANCE_MILES).to_i

    DirectorySegment.new.tap do |segment|
      segment.geocode
      segment.parent_segment = parent_segment
      segment.name = params[:city] || params[:country]

      segment.synthetic = true
    end
  end

  def populate_timezone
    timezone = self.attributes['timezone']
    if (self.coordinates_changed? || (timezone.blank? && self.coordinates.present?))
      self.timezone = RollFindr::TimezoneService.timezone_for(self.to_coordinates[0], self.to_coordinates[1]) rescue nil
    end
  end
end

