class Activity
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  
  TYPE_ACADEMY_CREATED = 1
  TYPE_ACADEMY_UPDATED = 2
  TYPE_INSTRUCTOR_CREATED = 3
  TYPE_MODERATION_REQUIRED = 4

  belongs_to :parent_activity, class_name: Activity.to_s, inverse_of: :children
  has_many :children, class_name: Activity.to_s, inverse_of: :parent_activity

  field :activity_type, type: Integer
  field :message, type: String

  field :coordinates, type: Array
  field :segment_key, type: String

  field :source_id
  field :source_type
  field :source_name

  field :entity_id
  field :entity_type

  field :data, type: Hash

  index(activity_type: 1)
  index(coordinates: '2dsphere')
  index(segment_key: 1)

  def lat
    self.coordinates.try(:[], 1)
  end

  def lng
    self.coordinates.try(:[], 0)
  end
end
