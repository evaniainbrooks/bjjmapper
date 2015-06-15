class LocationOwnerVerification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :location

  field :expires_at, type: Time
  field :closed_at, type: Time
  field :email, type: String

  before_create :set_expires

  scope :with_token, ->(token) { where(:_id => token).where(:expires_at.gte => Time.now) }

  def expired?
    self.expires_at < Time.now
  end

  def closed?
    self.closed_at.present?
  end

  def verify!
    attributes = { :owner => self.user }
    attributes.merge!({:email => self.email }) if self.email.present?

    location.update_attributes(attributes)
    
    self.update_attribute(:closed_at, Time.now)
  end

  private

  def set_expires
    self.expires_at = 10.days.from_now
  end
end
