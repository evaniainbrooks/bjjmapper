require 'mongoid-history'
require 'mongoid_search_ext'

class Location
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  include Mongoid::History::Trackable

  extend MongoidSearchExt::Search

  SLUG_STOP_WORDS = ['the', 'and', 'a', 's', 'on', 'is', 'slash', 'by'].freeze

  TYPE_ACADEMY = 0
  TYPE_EVENT_VENUE = 1

  track_history   :on => :all,
                  :modifier_field => :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  :modifier_field_inverse_of => nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false

  geocoded_by :address
  after_validation :geocode, if: ->(obj) { obj.address.present? and obj.changed? }
  after_validation :reverse_geocode

  reverse_geocoded_by :coordinates do |obj, results|
    geo = results.first
    if obj.address_components.include?(nil) && geo.present?
      obj.street = geo.street_address
      obj.city = geo.city
      obj.state = geo.state
      obj.postal_code = geo.postal_code
      obj.country = geo.country_code
    end
  end

  before_save :canonicalize_phone
  before_save :canonicalize_website
  before_save :canonicalize_facebook
  before_save :populate_timezone

  field :coordinates, type: Array
  field :street
  field :city
  field :state
  field :country
  field :postal_code

  field :title
  slug :title, history: true do |obj|
    (obj.title.parameterize.split('-') - SLUG_STOP_WORDS).join('-')
  end

  field :description
  field :directions
  field :image
  field :website
  field :phone
  field :email
  field :timezone
  field :facebook
  field :instagram
  field :twitter
  field :ig_hashtag
  field :loctype, type: Integer, default: TYPE_ACADEMY

  field :flag_closed, type: Boolean, default: false
  field :rating, default: 0.0

  validates :title, presence: true

  belongs_to :team, index: true
  belongs_to :owner, class_name: 'User', index: true, inverse_of: :owned_locations
  has_and_belongs_to_many :instructors, class_name: 'User', index: true, inverse_of: :locations
  has_and_belongs_to_many :favorited_by, class_name: 'User', index: true, inverse_of: :locations

  has_many :events
  has_many :reviews, :order => :created_at.desc

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

  default_scope -> { includes(:team).includes(:owner) }
  scope :academies, -> { where(:type => TYPE_ACADEMY) }
  scope :event_venue, -> { where(:type => TYPE_EVENT_VENUE) }

  def editable_by? user
    return true if user.super_user?
    return false if user.anonymous?

    !self.flag_claimed? || user.id.eql?(self.owner.id)
  end

  def flag_claimed?
    self.owner.present?
  end

  def to_param
    slug
  end

  def stars
    rating.floor
  end

  def half_star?
    (rating - rating.floor) >= 0.5
  end

  def address_components
    [street, city, state, country, postal_code]
  end

  def address
    address_components.select(&:present?).join(', ')
  end

  def team_name
    team.try(:name)
  end

  def as_json(args)
    # Hack around mongo ugly ids
    super(args.merge(except: [:coordinates, :_id, :modifier_id, :team_id, :instructor_ids])).merge({
      :id => self.to_param,
      :team_id => self.team_id.to_s,
      :modifier_id => self.modifier_id.to_s,
      :coordinates => self.to_coordinates,
      :timezone => self.timezone,
      :team_name => team_name,
      :address => address
    })
  end

  def schedule
    @location_schedule ||= LocationSchedule.new(self.id)
  end

  def timezone
    super || (populate_timezone unless self.destroyed?)
  end

  def coordinates=(coordinates)
    self.timezone = nil
    super
  end

  def ig_hashtag
    super || self.team.try(:ig_hashtag) || default_ig_hashtag
  end

  private

  def default_ig_hashtag
    'bjjmapper' + self.title.parameterize('').first(6)
  end

  def canonicalize_website
    self.website.gsub!(/^https?:\/\//, '') if self.website_changed?
  end

  def canonicalize_facebook
    self.facebook.gsub!(/(^https?:\/\/(www\.)?)|facebook\.com\/|fb\.com\//, '') if self.facebook_changed?
  end

  def canonicalize_phone
    self.phone.gsub!(/[^\d]/, '') if self.phone_changed?
  end

  def populate_timezone
    timezone = self.attributes['timezone']
    if (self.coordinates_changed? || (timezone.blank? && self.coordinates.present?))
      self.timezone = RollFindr::TimezoneService.timezone_for(self.to_coordinates[0], self.to_coordinates[1]) rescue nil
    end
  end
end
