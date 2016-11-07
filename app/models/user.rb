require 'wikipedia'
require 'mongoid_search_ext'

class User
  include Mongoid::Document
  include Mongoid::Slug
  include Geocoder::Model::Mongoid
  include Mongoid::Timestamps

  include Mongoid::History::Trackable
  include MongoidSearchExt::Search

  DEFAULT_THUMBNAIL_X = 50
  DEFAULT_THUMBNAIL_Y = 0

  VALID_IMAGE_MATCH = /(^https:\/\/(common)?datastorage.googleapis.com\/bjjmapper\/)|(^https:\/\/upload.wikimedia.org)/

  track_history   :on => :all,
                  :modifier_field => :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  :modifier_field_inverse_of => nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false

  field :role, type: String
  field :provider, type: String
  field :uid, type: String
  field :name, type: String
  slug :name, history: true do |obj|
    obj.anonymous? ? obj.ip_address.try(:to_url) : obj.name.to_url
  end

  field :api_key, type: String
  field :email, type: String
  field :contact_email, type: String
  field :thumbnailx, type: Integer, default: DEFAULT_THUMBNAIL_X
  field :thumbnaily, type: Integer, default: DEFAULT_THUMBNAIL_Y
  field :image_tiny, type: String
  field :image_large, type: String
  field :image, type: String
  field :ip_address, type: String
  field :coordinates, type: Array
  field :last_seen_at, type: Integer
  field :description, type: String
  field :description_read_more_url, type: String
  field :description_src, type: String

  field :oauth_token, type: String
  field :oauth_expires_at, type: Integer

  field :belt_rank, type: String
  field :stripe_rank, type: Integer
  field :birth_day, type: Integer
  field :birth_month, type: Integer
  field :birth_year, type: Integer
  field :birth_place, type: String
  field :internal, type: Boolean
  field :female, type: Boolean

  field :flag_display_email, type: Boolean, default: false
  field :flag_display_directory, type: Boolean, default: true
  field :flag_display_reviews, type: Boolean, default: true
  field :flag_locked, type: Boolean, default: -> { self.provider.present? }

  validates :name, presence: true

  validate :valid_image_prefix?

  geocoded_by :ip_address
  after_validation :safe_geocode

  belongs_to :lineal_parent, class_name: 'User', inverse_of: :lineal_children
  has_many :lineal_children, class_name: 'User', inverse_of: :lineal_parent
  has_many :reviews, inverse_of: :user
  has_many :owned_locations, class_name: 'Location', inverse_of: :owner

  belongs_to :redirect_to_user, class_name: 'User', inverse_of: :redirected_to_user
  has_one :redirected_to_user, class_name: 'User', inverse_of: :redirect_to_user

  has_and_belongs_to_many :teams
  has_and_belongs_to_many :locations, index: true, inverse_of: :instructors
  has_and_belongs_to_many :favorite_locations, class_name: 'Location', index: true, inverse_of: :favorited_by

  index({
      :name => 'text',
      :contact_email => 'text',
      :description => 'text'
    },
    {
      :name => 'user_text_index',
      :weights => {
        :name => 20,
        :description => 10,
        :contact_email => 10
      }
    }
  )

  default_scope -> { where(:redirect_to_user_id => nil) }
  scope :jitsukas, -> { where(:belt_rank.in => ['blue', 'purple', 'brown', 'black']) }

  def populate_from_wikipedia!
    page = Wikipedia.find(name)
    if page.content.present?
      self.image = page.image_urls.detect { |x| !x.end_with?('svg') } unless self.image.present?
      self.description_src = :wikipedia
      self.description = page.summary.gsub(/\n/, "\r\n\r\n")
      self.description_read_more_url = page.fullurl
      self.save
    end
  end

  def can_destroy? object
    if object.respond_to?(:destroyable_by?)
      object.destroyable_by? self
    else
      object.editable_by? self
    end
  end

  def can_edit? object
    object.editable_by? self
  end

  def editable_by? user
    return true if user.super_user?
    return false if user.anonymous?

    !self.flag_locked? || user.id.eql?(self.id)
  end

  def jitsuka?
    self.belt_rank.present?
  end

  def self.rank_sort_key(belt_rank, stripe_rank)
    belt = belt_rank.try(:downcase) || 'white'
    stripe = stripe_rank || 0
    key = {'white' => 0, 'blue' => 100, 'purple' => 200, 'brown' => 300, 'black' => 400}[belt] + stripe
    return -key
  end

  def self.anonymous(ip_address)
    User.where(ip_address: ip_address).first_or_create(provider: 'anonymous', role: 'anonymous', name: "Anonymous #{ip_address}", last_seen_at: Time.now)
  end

  def self.from_omniauth(auth, ip_address)
    email = auth.try(:[], 'info').try(:[], 'email')
    User.where(provider: auth['provider'], uid: auth['uid'])
        .first_or_initialize(
          name: auth.try(:[], 'info').try(:[], 'name'),
          email: email,
          contact_email: email,
          ip_address: ip_address,
          oauth_token: auth.try(:credentials).try(:token),
          oauth_expires_at: Time.at(auth.try(:credentials).try(:expires_at) || 0),
          last_seen_at: Time.now
        )
  end

  def anonymous?
    self.role.try(:to_s).try(:eql?, 'anonymous')
  end

  def super_user?
    self.role.try(:to_s).try(:eql?, 'super_user')
  end

  def schedule
    @_schedule ||= UserSchedule.new(self.id)
  end

  def full_lineage
    # TODO: Is this expensive? Is caching enough?
    lineage = []
    u = self.lineal_parent
    while u.present?
      lineage << u
      u = u.lineal_parent
      break if lineage.count > 10
    end
    lineage
  end

  def birthdate
    return nil unless birth_year.present? && birth_month.present? && birth_day.present?
    Date.new(birth_year, birth_month, birth_day) rescue nil
  end

  def age_in_years
    d = Time.now
    a = d.year - birth_year
    a = a - 1 if (
         birth_month >  d.month or
        (birth_month >= d.month and birth_day > d.day)
    )
    a
  end

  def to_param
    slug || id
  end

  def as_json(args = {})
    raise StandardError, "Use a JBuilder template"
  end

  private

  def valid_image_prefix?
    if self.image_tiny.present? && VALID_IMAGE_MATCH.match(self.image_tiny).blank?
      errors.add(:image_tiny, 'invalid image url')
    end
    if self.image.present? && VALID_IMAGE_MATCH.match(self.image).blank?
      errors.add(:image, 'invalid image url')
    end
    if self.image_large.present? && VALID_IMAGE_MATCH.match(self.image_large).blank?
      errors.add(:image_large, 'invalid image url')
    end
  end

  def safe_geocode
    begin
      geocode
    rescue StandardError => e
      Rails.logger.error(e)
    end
  end
end

