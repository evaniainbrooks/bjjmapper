require 'mongoid_search_ext'

class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  include Mongoid::History::Trackable

  extend MongoidSearchExt::Search

  track_history   :on => :all,
                  :modifier_field => :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  :modifier_field_inverse_of => :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false

  geocoded_by :address
  after_validation :geocode, if: ->(obj) { obj.address.present? and obj.changed? }
  after_validation :reverse_geocode

  reverse_geocoded_by :coordinates do |obj, results|
    geo = results.first
    if obj.address.blank? && geo.present?
      obj.street = geo.street_address
      obj.city = geo.city
      obj.state = geo.state
      obj.postal_code = geo.postal_code
      obj.country = geo.country_code
    end
  end

  field :coordinates, :type => Array
  field :street
  field :city
  field :state
  field :country
  field :postal_code
  field :title
  field :description
  field :directions
  field :image
  field :website
  field :phone
  field :email
  field :facebook

  validates :title, presence: true

  belongs_to :team, index: true
  has_and_belongs_to_many :instructors, class_name: 'User', index: true
  has_many :events

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

  def address
    [street, city, state, country, postal_code].compact.join(', ')
  end

  def team_name
    team.try(:name)
  end

  def as_json(args)
    # Hack around mongo ugly ids
    super(args.merge(except: [:coordinates, :_id, :modifier_id, :team_id, :instructor_ids])).merge({
      :id => self.id.to_s,
      :team_id => self.team_id.to_s,
      :modifier_id => self.modifier_id.to_s,
      :instructors => self.instructor_ids.map(&:to_s),
      :coordinates => self.to_coordinates,
      :team_name => team_name,
      :address => address
    })
  end
end
