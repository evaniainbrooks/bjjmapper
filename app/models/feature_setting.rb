require 'mongoid'

class FeatureSetting
  include Mongoid::Document

  field :name, type: String
  field :value, type: Boolean

  validate :name, presence: true

  def self.enabled?(name)
    FeatureSetting.where(name: name).first_or_initialize(value: false).value
  end

  def self.enable(name, value)
    FeatureSetting.where(name: name).first_or_initialize.tap do |feature|
      feature.value = value
      feature.save!
    end
  end
end
