require 'mongoid_search_ext'

class Organization
  include Canonicalized
  
  include Mongoid::Document
  include Mongoid::Slug
  include Geocoder::Model::Mongoid
  include Mongoid::Timestamps

  include Mongoid::History::Trackable
  include MongoidSearchExt::Search

  field :name, type: String
  field :abbreviation, type: String
  field :description, type: String
  field :image, type: String
  field :image_large, type: String
  field :website, type: String
  field :email, type: String

  validates :name, presence: true
  validates :abbreviation, presence: true
  validates :website, presence: true

  canonicalize :website, as: :website

  has_many :events, inverse_of: :organization
end
