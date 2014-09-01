class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  include Mongoid::History::Trackable

  INDEPENDENT = "Independent"

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
    if obj.address.blank? and geo = results.first
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
  belongs_to :team
  belongs_to :user
  belongs_to :head_instructor, class_name: 'User'

  def address
    [street, city, state, country, postal_code].compact.join(', ')
  end

  def team_name
    team.try(:name) || INDEPENDENT
  end

  def as_json args
    # Hack around mongo ugly ids
    result = super(args.merge(except: [:_id, :team_id])).merge({
      :id => self.id.to_s,
      :team_name => team_name
    })
  end
end
