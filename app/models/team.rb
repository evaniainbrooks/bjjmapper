require 'mongoid-history'
require 'mongoid_search_ext'

class Team
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  extend MongoidSearchExt::Search

  track_history   :on => :all,
                  :modifier_field => :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  :modifier_field_inverse_of => :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false
  field :name, type: String
  slug :name, history: true

  field :description, type: String
  field :image_tiny, type: String
  field :image, type: String
  field :image_large, type: String
  field :cover_image
  field :cover_image_x, default: 0, type: Integer
  field :cover_image_y, default: 0, type: Integer
  field :primary_color_index, type: String
  field :locked, type: Boolean

  index({
      :name => 'text',
      :description => 'text'
    },
    {
      :name => 'team_text_index',
      :weights => {
        :name => 20,
        :description => 10
      }
    }
  )

  has_many :locations, order: :title.asc
  belongs_to :parent_team, class_name: 'Team', inverse_of: :child_teams
  has_many :child_teams, class_name: 'Team', inverse_of: :parent_team

  has_and_belongs_to_many :instructors, class_name: 'User', index: true

  validates :name, presence: true

  def destroyable_by? user
    return self.locations.size == 0 && self.editable_by?(user)
  end

  def editable_by? user
    return !self.locked? || user.super_user?
  end

  def to_param
    slug
  end

  def as_json(args = {})
    raise StandardError, "Use a JBuilder template"
  end
end
