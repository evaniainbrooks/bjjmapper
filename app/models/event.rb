class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  field :title, type: String
  field :description, type: String
  field :starting, type: Time
  field :ending, type: Time
  field :is_all_day, type: Boolean
  field :price, type: String
  field :type, type: String

  scope :before_time, ->(time) { where(:ending.gte => time) }
  scope :after_time, ->(time) { where(:starting.lte => time) }
  scope :between_time, ->(start_time, end_time) { where(:starting.gte => start_time, :starting.lte => end_time) }

  embeds_one :event_recurrence
  accepts_nested_attributes_for :event_recurrence

  belongs_to :modifier, class_name: 'User'
  belongs_to :location
  belongs_to :instructor, class_name: 'User'

  validates :title, :presence => true
  validates :location, :presence => true
  validates :modifier, :presence => true
  validates :instructor, :presence => true

  validates :starting, :presence => true
  validates :ending, :presence => true
  validate :ending_is_after_starting

  def recurrence=(rule)
    self.event_recurrence = EventRecurrence.new if self.event_recurrence.blank?
    self.event_recurrence.rule = rule
  end

  def starting=(v)
    v = Time.at(v.to_i).to_datetime unless v.is_a?(DateTime) || v.blank?
    super(v)
  end

  def ending=(v)
    v = Time.at(v.to_i).to_datetime unless v.is_a?(DateTime) || v.blank?
    super(v)
  end

  def as_json(args)
    {
      :id => self.id.try(:to_s),
      :title => self.title,
      :description => self.description,
      :start => self.starting,
      :end => self.ending,
      :type => self.type,
      :instructor => self.instructor.try(:to_param),
      :location => self.location.try(:to_param),
      :allDay => self.is_all_day,
      :recurring => self.event_recurrence.present?,
      :url => nil #Rails.application.routes.url_helpers.location_event_path(self.location, self),
    }
  end

  private

  def ending_is_after_starting
    if self.ending.present? && self.starting.present? && self.ending <= self.starting
      errors.add(:ending, "Ending must come after starting")
    end
  end
end
