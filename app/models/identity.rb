class Identity
  include Mongoid::Document
  include OmniAuth::Identity::Models::Mongoid
  field :name, type: String
  field :email, type: String
  field :password_digest, type: String

  validates :name, presence: true
  validates :email, presence: true
  validates :password_digest, presence: true
end
