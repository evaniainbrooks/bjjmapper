require 'mongoid-history'
require 'mongoid_search_ext'
require 'redis_cache'
require 'ice_cube'

class Event
  include Canonicalized

  RECURRENCE_NONE = 0
  RECURRENCE_DAILY = 1
  RECURRENCE_2DAILY = 2
  RECURRENCE_WEEKLY = 3
  RECURRENCE_2WEEKLY = 4

  EVENT_TYPE_CLASS = 1
  EVENT_TYPE_SEMINAR = 2
  EVENT_TYPE_TOURNAMENT = 4
  EVENT_TYPE_CAMP = 8
  EVENT_TYPE_SUBEVENT = 16
  EVENT_TYPE_OPENING_HOURS = 32

  EVENT_TYPE_ALL = [EVENT_TYPE_CLASS, EVENT_TYPE_SEMINAR, EVENT_TYPE_TOURNAMENT, EVENT_TYPE_CAMP, EVENT_TYPE_OPENING_HOURS].freeze

  CREATE_PARAMS_WHITELIST = [
    :event_type,
    :organization,
    :starting,
    :ending,
    :event_recurrence,
    :title,
    :description,
    :instructor,
    :location,
    :parent_event,
    :email,
    :website,
    :facebook,
    :weekly_recurrence_days => []].freeze

  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  extend MongoidSearchExt::Search

  attr_accessor :event_recurrence
  attr_accessor :weekly_recurrence_days

  field :title, type: String
  field :description, type: String
  field :starting, type: Time
  field :ending, type: Time
  field :is_all_day, type: Boolean
  field :price, type: String
  field :email, type: String
  field :website, type: String
  field :facebook, type: String
  field :event_type, type: Integer, default: EVENT_TYPE_CLASS
  field :source, type: String

  field :lat
  field :lng
  field :country

  default_scope -> { where(:event_type.ne => EVENT_TYPE_SUBEVENT).asc(:starting) }

  scope :before_time, ->(time) { where(:ending.gte => time) }
  scope :after_time, ->(time) { where(:starting.lte => time) }
  scope :between_time, ->(start_time, end_time) { where(:starting.gte => start_time, :starting.lte => end_time) }

  scope :classes, -> { where(:event_type => EVENT_TYPE_CLASS) }
  scope :seminars, -> { where(:event_type => EVENT_TYPE_SEMINAR) }
  scope :camps, -> { where(:event_type => EVENT_TYPE_CAMP) }
  scope :tournaments, -> { where(:event_type => EVENT_TYPE_TOURNAMENT) }

  belongs_to :modifier, class_name: 'User'
  belongs_to :location
  belongs_to :instructor, class_name: 'User'
  belongs_to :organization

  belongs_to :parent_event, class_name: 'Event', :inverse_of => :sub_events
  has_many :sub_events, class_name: 'Event', :inverse_of => :parent_event

  validates :title, :presence => true
  slug :title, history: true

  validates :location, :presence => true
  validates :modifier, :presence => true

  validates :starting, :presence => true
  validates :ending, :presence => true
  validate :ending_is_after_starting
  validate :organizer_or_instructor_present

  field :schedule

  before_save :set_coordinates
  before_save :set_event_type
  before_save :create_schedule
  before_save :serialize_schedule

  canonicalize :website, as: :website
  canonicalize :facebook, as: :facebook

  index :event_type => 1
  index :ending => 1
  index :starting => 1

  index({
    :title => 'text',
    :description => 'text',
    :email => 'text',
    :website => 'text',
    :facebook => 'text'
  },
  {
    :name => 'event_text_index',
    :weights => {
      :title => 20,
      :description => 10,
      :email => 5,
      :website => 5,
      :facebook => 5
    }
  })

  def to_param
    slug || id.try(:to_s)
  end

  def as_json(args = {})
    raise StandardError, "Use a JBuilder template"
  end

  def schedule
    @schedule ||= begin
      yaml = read_attribute(:schedule)
      if yaml.present?
        IceCube::Schedule.from_yaml(yaml)
      else
        IceCube::Schedule.new self.starting
      end
    end
  end

  def recurrence_type
    case self.schedule.try(:rrules).try(:first)
    when IceCube::WeeklyRule
      self.schedule.rrules.first.to_hash[:interval] == 1 ? RECURRENCE_WEEKLY : RECURRENCE_2WEEKLY
    when IceCube::DailyRule
      self.schedule.rrules.first.to_hash[:interval] == 1 ? RECURRENCE_DAILY : RECURRENCE_2DAILY
    else
      RECURRENCE_NONE
    end
  end

  def recurring?
    self.recurrence_type != RECURRENCE_NONE
  end

  def recurrence_days
    self.schedule.try(:rrules).try(:first).try(:to_hash).try(:[], :validations).try(:[], :day)
  end

  private

  def serialize_schedule
    write_attribute(:schedule, @schedule.to_yaml) if @schedule.present? && @schedule.rrules.present?
  end

  def ending_is_after_starting
    if self.ending.present? && self.starting.present? && self.ending <= self.starting
      errors.add(:ending, "Ending must come after starting")
    end
  end

  def organizer_or_instructor_present
    if self.event_type == Event::EVENT_TYPE_TOURNAMENT && self.organization.blank?
      errors.add(:organization, "Tournaments require an organization")
    end

    if self.event_type == Event::EVENT_TYPE_SEMINAR && self.instructor.blank?
      errors.add(:instructor, "Seminars require an instructor")
    end
  end

  def remove_existing_recurrence_rules
    self.schedule.rrules.each do |rule|
      self.schedule.remove_recurrence_rule rule
    end
  end

  def create_schedule
    return unless self.event_recurrence.present?
    return unless self.event_type == Event::EVENT_TYPE_CLASS

    remove_existing_recurrence_rules

    case self.event_recurrence.try(:to_i)
    when RECURRENCE_DAILY
      self.schedule.add_recurrence_rule IceCube::Rule.daily
    when RECURRENCE_2DAILY
      self.schedule.add_recurrence_rule IceCube::Rule.daily(2)
    when RECURRENCE_WEEKLY
      self.schedule.add_recurrence_rule IceCube::Rule.weekly(1).day(*weekly_recurrence_days.try(:map, &:to_i))
    when RECURRENCE_2WEEKLY
      self.schedule.add_recurrence_rule IceCube::Rule.weekly(2).day(*weekly_recurrence_days.try(:map, &:to_i))
    end
  end

  def set_event_type
    if self.parent_event.present?
      self.location = self.parent_event.location
      self.event_type = EVENT_TYPE_SUBEVENT
      self.schedule = nil
    end
  end

  def set_coordinates
    self.lat = self.location.lat
    self.lng = self.location.lng
    self.country = self.location.country
  end
end
