class Team
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :image, type: String
  has_many :locations
  has_many :users
  belongs_to :parent_team, class_name: 'Team'
end
