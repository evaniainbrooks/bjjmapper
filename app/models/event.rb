class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  #[{"TaskID":4,"OwnerID":2,"Title":"Bowling tournament","Description":"","StartTimezone":null,"Start":"\/Date(1370811600000)\/","End":"\/Date(1370822400000)\/","EndTimezone":null,"RecurrenceRule":null,"RecurrenceID":null,"RecurrenceException":null,"IsAllDay":false}
  field :title, type: String
  field :description, type: String
  field :starting, type: DateTime
  field :ending, type: DateTime
  field :recurrence_id, type: Integer
  field :is_all_day, type: Boolean
  field :recurrence, type: String

  scope :before, ->(time) { where(:ending.gte => time) }
  scope :after, ->(time) { where(:starting.lte => time) }
  scope :between, ->(start_time, end_time) { where(:starting.gte => start_time, :starting.lte => end_time) }

  belongs_to :location
  belongs_to :instructor, class_name: 'User'

  validates :title, :presence => true
  validates :location, :presence => true

  #TODO validate ending is after starting

  def as_json(args)
    {
      :id => self.id.to_s,
      :title => self.title,
      :description => self.description,
      :start => self.starting,
      :end => self.ending,
      :allDay => self.is_all_day,
      # TODO: Revisit these values
      :recurring => false,
      :url => Rails.application.routes.url_helpers.location_event_path(self.location.id, self.id)
    }
  end
end
