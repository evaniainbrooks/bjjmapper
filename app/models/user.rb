require 'wikipedia'

class User
  include Mongoid::Document
  include Geocoder::Model::Mongoid
  include Mongoid::Timestamps

  field :role, type: String
  field :provider, type: String
  field :uid, type: String
  field :name, type: String
  field :email, type: String
  field :image, type: String
  field :ip_address, type: String
  field :coordinates, type: Array
  field :last_seen_at, type: Integer
  field :description, type: String
  field :summary, type: String
  field :description_src, type: String

  field :oauth_token, type: String
  field :oauth_expires_at, type: Integer

  field :belt_rank, type: String
  field :stripe_rank, type: Integer

  geocoded_by :ip_address
  after_validation :geocode

  belongs_to :team
  has_and_belongs_to_many :locations

  before_create do
    if :instructor == role.try(:to_sym)
      page = Wikipedia.find(name)
      if page.content.present?
        self.image = page.image_urls.last
        self.description_src = :wikipedia
        self.description = page.content
      end
    end
  end

  def self.from_omniauth(auth, ip_address)
    User.where(provider: auth['provider'], uid: auth['uid'])
        .first_or_create(
          name: auth.try(:[], 'info').try(:[], 'name'),
          email: auth.try(:[], 'info').try(:[], 'email'),
          ip_address: ip_address,
          oauth_token: auth.try(:credentials).try(:token),
          oauth_expires_at: Time.at(auth.try(:credentials).try(:expires_at) || 0),
          last_seen_at: Time.now
        )
  end

  def as_json(args)
    super(args.merge(except: [:ip_address, :coordinates, :uid, :provider, :email, :_id])).merge({
      :id => self.id.to_s
    })
  end
end

