class Review
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :author_name
  attr_accessor :author_link
  attr_accessor :src

  belongs_to :user, index: true
  belongs_to :location, index: true

  field :body
  field :rating

  validates :user, presence: true
  validates :location, presence: true
  validates :body, presence: true
  validates :rating, presence: true, inclusion: 1..5

  def as_json(args = {})
    raise StandardError, "Use a JBuilder template"
  end
end
