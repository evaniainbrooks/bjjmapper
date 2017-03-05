class ModerationNotification
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  TYPE_DUPLICATE_LOCATION = 1
  TYPE_DUPLICATE_PERSON = 2
  TYPE_REVIEW_LOCATION = 3

  validates :type, presence: true
  validates :source, presence: true
  validates :message, presence: true

  belongs_to :dismissed_by_user, class_name: 'User'

  index(coordinates: '2dsphere')
 
  field :type, type: Integer
  field :source, type: String
  field :message, type: String
  field :info, type: Hash
  field :coordinates, type: Array

  def dismissed?
    return dismissed_by_user.present?
  end

  def dismiss!(user)
    dismissed_by_user = user
    save!
  end
end
