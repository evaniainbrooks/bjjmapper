class LocationOwnerVerification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :location

  field :expires_at, type: Time

  before_create :set_expires

  scope :with_token, ->(token) { where(:_id => token).where(:expires_at.gte => Time.now) }

  def expired?
    self.expires_at < Time.now
  end

  private

  def set_expires
    self.expires_at = 10.days.from_now
  end
end
