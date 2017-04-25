require 'mongoid-history'
require 'redis_cache'
require 'i18n'

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

  field :flag_index_visible, type: Boolean, default: false
  field :zoom, type: Integer
  field :distance, type: Integer, default: DEFAULT_DISTANCE_MILES
  field :timezone, type: String

  belongs_to :parent_segment, class_name: 'DirectorySegment', inverse_of: :child_segments
  has_many :child_segments, class_name: 'DirectorySegment', inverse_of: :parent_segment

  scope :visible_in_index, -> { where(:flag_index_visible.ne => false) }
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

  def name_segments
    [self.name, self.parent_segment.try(:name)].compact
  end

  def full_name
    name_segments.join(', ')
  end

  def timezone
    super || (populate_timezone unless self.destroyed?)
  end

  def lat=(val)
    self.coordinates[1] = val
  end

  def lng=(val)
    self.coordinates[0] = val
  end

  def lat
    self.to_coordinates[0]
  end

  def lng
    self.to_coordinates[1]
  end

  def coordinates=(coordinates)
    self.timezone = nil
    super
  end

  def abbreviations
    (self.attributes['abbreviations'] || []).concat(
      RollFindr::DirectoryCountryAbbreviations[I18n.transliterate(name).downcase] || []
    )
  end

  def location_count
    key = ['SegmentLocationCount', self.id.to_s].join('-')
    RollFindr::Redis.cache(key: key, expire: rand(10.hours.seconds..10.days.seconds)) do
      locations.count
    end
  end

  def locations
    @_locations ||= if self.child?
      Location.where(:coordinates => { "$geoWithin" => { "$centerSphere" => [self.coordinates, self.distance/3963.2] }})
    else
      Location.where(:country.in => self.abbreviations.push(self.name))
    end
  end
  
  def notifications
    @_notifications ||= if self.child?
      ModerationNotification.where(:coordinates => { "$geoWithin" => { "$centerSphere" => [self.coordinates, self.distance/3963.2] }})
    else
      ModerationNotification.where(:country.in => self.abbreviations.push(self.name))
    end
  end

  def to_param
    slug || name_segments
  end

  def child?
    self.parent_segment.present?
  end

  def parent?
    !self.child_segments.empty?
  end

  def as_json(args = {})
    raise StandardError, "Use a JBuilder template"
  end

  private

  def self.synthesize(params, parent_segment = nil)
    distance = params.fetch(:distance, DEFAULT_DISTANCE_MILES).to_i

    canonical_name = params[:city] || params[:country]
    DirectorySegment.new.tap do |segment|
      segment.name = canonical_name
      segment.parent_segment = parent_segment
      segment.geocode
      segment.timezone
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

