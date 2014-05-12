class User
  include Mongoid::Document
  include Geocoder::Model::Mongoid
  include Mongoid::Timestamps
  
  field :provider, type: String
  field :uid, type: String
  field :name, type: String
  field :email, type: String
  field :ip_address, type: String

  geocoded_by :ip_address, latitude: :lat, longitude: :lon
  after_validation :geocode

  belongs_to :team

  def self.create_with_omniauth(auth, ip_address)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
        user.name = auth['info']['name'] || ""
        user.email = auth['info']['email'] || ""
      end
      user.ip_address = ip_address
    end
  end
end

