require 'mongoid'

class FeatureSetting
  include Mongoid::Document

  field :name, type: String
  field :value, type: Boolean

  validate :name, presence: true

  VALID_FEATURE_SETTINGS = [
    :hide_global_ads,
    :hide_bjjatlas_events,
    :hide_homepage_new_additions,
    :hide_homepage_directory_segments,
    :hide_locations_with_missing_street,
    :show_activities,
    :show_articles
  ].freeze

  def self.enabled?(name)
    raise ArgumentError, "#{name} is not a valid feature setting!" unless VALID_FEATURE_SETTINGS.include?(name)
    
    FeatureSetting.where(name: name).first_or_initialize(value: false).value
  end

  def self.enable(name, value)
    raise ArgumentError, "#{name} is not a valid feature setting!" unless VALID_FEATURE_SETTINGS.include?(name)

    FeatureSetting.where(name: name).first_or_initialize.tap do |feature|
      feature.value = value
      feature.save!
    end
  end
end
