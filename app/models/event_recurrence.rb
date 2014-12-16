require 'ice_cube'

class EventRecurrence
  include Mongoid::Document
  include Mongoid::Timestamps
  field :recurrence_rule, type: String
  embedded_in :event
  validates :recurrence_rule, presence: true

  before_save do
    self.recurrence_rule = @rule.to_yaml if defined?(@rule)
  end

  def rule
    @rule = IceCube::Rule.from_yaml(self.recurrence_rule) if self.recurrence_rule.present?
    @rule
  end

  def rule=(rule)
    @rule = nil
    self.recurrence_rule = rule.to_yaml
    rule
  end
end
