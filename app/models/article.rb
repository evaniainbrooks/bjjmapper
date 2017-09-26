require 'mongoid'

class Article
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  
  SLUG_STOP_WORDS = Location::SLUG_STOP_WORDS
  
  STATUS_UNPUBLISHED = 0
  STATUS_PUBLISHED = 2

  slug :title
  
  track_history   :on => :all,
                  :modifier_field => :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  :modifier_field_inverse_of => nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false

  field :modifier_id
  field :title
  field :body
  field :status, type: Integer, default: STATUS_UNPUBLISHED
  field :author_id
  field :coordinates, type: Array, default: Array.new(2)
  field :location

  scope :published, -> { where(:status => STATUS_UNPUBLISHED) }
  scope :unpublished, -> { where(:status.ne => STATUS_PUBLISHED) }

  belongs_to :author, class_name: 'User' 

  def publish! as_user
    update_attributes!(author: as_user, modifier: as_user, status: STATUS_PUBLISHED)
  end

  def unpublish! as_user
    update_attributes!(author: as_user, modifier: as_user, status: STATUS_UNPUBLISHED)
  end
  
  def to_param
    slug
  end
  
  def to_coordinates
    coordinates.reverse
  end

  def lat
    to_coordinates.try(:[], 0)
  end

  def lng
    to_coordinates.try(:[], 1)
  end
end
