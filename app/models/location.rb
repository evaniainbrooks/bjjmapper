require 'mongoid-history'
require 'mongoid_search_ext'
require 'redis_cache'

class Location
  include Canonicalized

  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps

  include Mongoid::History::Trackable

  extend MongoidSearchExt::Search

  SLUG_STOP_WORDS = ['the', 'and', 'a', 's', 'on', 'is', 'slash', 'by'].freeze

  LOCATION_TYPE_ACADEMY = 1
  LOCATION_TYPE_EVENT_VENUE = 2

  LOCATION_TYPE_ALL = [LOCATION_TYPE_ACADEMY, LOCATION_TYPE_EVENT_VENUE].freeze

  STATUS_PENDING = 1
  STATUS_VERIFIED = 2
  STATUS_REJECTED = 3

  track_history   :on => :all,
                  :modifier_field => :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  :modifier_field_inverse_of => nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false

  before_validation :generate_event_venue_title

  before_save :set_profile_associations
  before_save :set_closed_flag
  before_save :populate_timezone
  before_save :set_has_black_belt_flag

  after_create :maybe_search_metadata!

  field :status_updated_at, type: Integer
  field :status, type: Integer, default: STATUS_VERIFIED
  field :google_places_id, type: Integer
  field :coordinates, type: Array
  field :street
  field :city
  field :state
  field :country
  field :postal_code
  field :source, type: String

  field :title
  slug :title, history: true do |obj|
    (obj.title.parameterize.split('-') - SLUG_STOP_WORDS).join('-')
  end

  field :description
  field :directions
  field :cover_image
  field :cover_image_x, default: 0, type: Integer
  field :cover_image_y, default: 0, type: Integer
  field :image
  field :image_large
  field :image_tiny
  field :website
  field :phone
  field :email
  field :timezone
  field :facebook # Deprecated

  attr_accessor :facebook_id
  attr_accessor :google_id
  attr_accessor :yelp_id

  field :instagram
  field :twitter
  field :ig_hashtag
  field :loctype, type: Integer, default: LOCATION_TYPE_ACADEMY

  field :flag_has_black_belt, type: Boolean, default: false
  field :flag_closed, type: Boolean, default: false

  canonicalize :website, as: :website
  canonicalize :facebook, as: :facebook # Deprecated
  canonicalize :phone, as: :phone

  belongs_to :moved_to_location, class_name: 'Location', inverse_of: :moved_from_location
  has_one :moved_from_location, class_name: 'Location', inverse_of: :moved_to_location

  validates :title, presence: true
  validates :coordinates, presence: true

  belongs_to :team, index: true
  belongs_to :owner, class_name: 'User', index: true, inverse_of: :owned_locations
  has_and_belongs_to_many :instructors, class_name: 'User', index: true, inverse_of: :locations

  has_and_belongs_to_many :favorited_by, class_name: 'User', index: true, inverse_of: :locations

  has_many :events
  has_many :reviews, :order => :created_at.desc

  index :loctype => 1
  index :flag_closed => 1
  index :flag_has_black_belt => 1
  index :status => 1
  index({
    :street => 'text',
    :city => 'text',
    :state => 'text',
    :country => 'text',
    :postal_code => 'text',
    :title => 'text',
    :description => 'text',
    :directions => 'text',
    :image => 'text',
    :website => 'text',
    :phone => 'text',
    :email => 'text'
  },
  {
    :name => 'loc_text_index',
    :weights => {
      :street => 5,
      :city => 5,
      :state => 5,
      :country => 5,
      :postal_code => 5,
      :title => 20,
      :description => 15,
      :directions => 5,
      :image => 2,
      :website => 10,
      :phone => 10,
      :email => 10
    }
  })

  default_scope -> { includes(:owner).includes(:team) }
  scope :pending, -> { where(:status => STATUS_PENDING) }
  scope :not_pending, -> { where(:status.ne => STATUS_PENDING) }
  scope :verified, -> { where(:status.in => [nil, STATUS_VERIFIED]) }
  scope :rejected, -> { where(:status => STATUS_REJECTED) }
  scope :not_rejected, -> { where(:status.ne => STATUS_REJECTED) }

  scope :academies, -> { where(:loctype => LOCATION_TYPE_ACADEMY) }
  scope :event_venues, -> { where(:loctype => LOCATION_TYPE_EVENT_VENUE) }
  scope :with_black_belt, -> { where(:flag_has_black_belt => true) }

  scope :not_closed, -> { where(:flag_closed.ne => true) }

  def academy?
    self.loctype == Location::LOCATION_TYPE_ACADEMY
  end

  def event_venue?
    self.loctype == Location::LOCATION_TYPE_EVENT_VENUE
  end

  def editable_by? user
    return true if user.super_user?
    return false if user.anonymous?
    return false if self.flag_closed?

    !self.flag_claimed? || user.id.eql?(self.owner.id)
  end

  def flag_claimed?
    self.owner.present?
  end

  def schedule_updated_at
    self.events.last.try(:updated_at)
  end

  def to_param
    slug
  end

  def rating
    all_reviews.try(:rating) || 0.0
  end

  def stars
    all_reviews.try(:rating).try(:floor) || 0
  end

  def half_star?
    return false unless all_reviews.try(:rating).present?
    (all_reviews.rating - all_reviews.rating.floor) >= 0.5
  end

  def address_components
    {
      :street => street,
      :city => city,
      :state => state,
      :country => country,
      :postal_code => postal_code
    }
  end

  def address_changed?
    address_components.keys.detect{|k| self.send("#{k}_changed?") }.present?
  end

  def address
    address_components.values.compact.join(', ')
  end

  def team_name
    team.try(:name)
  end

  def as_json(args = {})
    raise StandardError, "Use a JBuilder template"
  end

  def schedule
    @location_schedule ||= LocationSchedule.new(self.id)
  end

  def timezone
    super || (populate_timezone unless self.destroyed?)
  end

  def lat
    self.to_coordinates[0]
  end

  def lng
    self.to_coordinates[1]
  end

  def to_coordinates
    self.coordinates.reverse
  end

  def coordinates=(coordinates)
    self.timezone = nil
    super
  end

  def ig_hashtag
    super || self.team.try(:ig_hashtag) || default_ig_hashtag
  end

  def has_generated_title?
    return self.title == self.address_components.values.join('-')
  end

  def expire_reviews_cache!
    RollFindr::Redis.del(reviews_cache_key)
  end

  def all_reviews
    @_all_reviews ||= RollFindr::Redis.cache(expire: 1.day.seconds, key: reviews_cache_key) do
      LocationReviews.new(self.id.to_s)
    end
  end

  def search_metadata!
    params = {
      lat: self.lat,
      lng: self.lng,
      title: self.title,
      street: self.street,
      city: self.city,
      state: self.state,
      postal_code: self.postal_code,
      country: self.country
    }

    if self.academy?
      RollFindr::LocationFetchService.search(self.id.to_s, location: params) == 202
    else
      false
    end
  end

  private

  def reviews_cache_key
   [LocationReviews, self.id.to_s].collect(&:to_s).join('-')
  end

  def maybe_search_metadata!
    if self.status == STATUS_VERIFIED
      self.search_metadata!
    end
  end

  def generate_event_venue_title
    if self.event_venue? && self.title.blank?
      self.title = self.address_components.values.join('-')
    end
  end

  def set_closed_flag
    self.flag_closed = true if self.moved_to_location.present?
    return true
  end

  def populate_timezone
    timezone = self.attributes['timezone']
    if (self.coordinates_changed? || (timezone.blank? && self.coordinates.present?))
      response = RollFindr::TimezoneService.timezone_for(self.lat, self.lng) rescue nil
      self.timezone = response unless response.blank?
    end
  end

  def set_has_black_belt_flag
    self.flag_has_black_belt = self.instructors.any?{|i| i.belt_rank == 'black'}
    return true
  end

  def set_profile_associations
    [:yelp, :facebook, :google].each do |profile|
      idfield = "#{profile}_id".to_sym
      val = self.send(idfield)
      if val
        params = { scope: profile }
        params[idfield] = val
        RollFindr::LocationFetchService.associate(self.id.to_s, params)
      end
    end
  end
end
