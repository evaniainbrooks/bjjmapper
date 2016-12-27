class Review
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user, index: true
  belongs_to :location, index: true

  field :author_name
  field :author_link
  field :src
  field :src_id
  field :src_group_id
  field :body
  field :rating

  field :lat
  field :lng
  field :country

  validates :location, presence: true
  validates :rating, presence: true, inclusion: 1..5

  def as_json(args = {})
    raise StandardError, "Use a JBuilder template"
  end
end
