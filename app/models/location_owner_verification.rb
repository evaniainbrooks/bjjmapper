class LocationOwnerVerification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :location

  field :expires_at, type: Time
  field :closed_at, type: Time
  field :email, type: String

  validates :email, presence: true
  validates :user, presence: true
  validates :location, presence: true

  before_create :set_expires

  scope :with_token, ->(token) { where(:_id => token).where(:expires_at.gte => Time.now) }

  def expired?
    self.expires_at < Time.now
  end

  def closed?
    self.closed_at.present?
  end

  def verify!
    attributes = { :owner => self.user, :email => self.email }
    location.update_attributes(attributes)

    self.update_attribute(:closed_at, Time.now)
  end

  def as_json(args = {})
    raise StandardError, "Use a JBuilder template"
  end

  private

  def set_expires
    self.expires_at = 10.days.from_now
  end
end
