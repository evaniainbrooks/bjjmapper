require 'active_support/concern'

module Canonicalized
  extend ActiveSupport::Concern

  WEBSITE_PATTERN = /^https?:\/\//
  FACEBOOK_PATTERN = /(^https?:\/\/(www\.)?)|(facebook\.com|fb\.com)(\/pg)?\//
  PHONE_PATTERN = /[^\d+]/

  module ClassMethods
    def canonicalize(field, options = {})
      before_save do |record|
        if record.send("#{field}_changed?")
          value = record.send(field)

          case options[:as] || field
          when :website then value.gsub!(Canonicalized::WEBSITE_PATTERN, '')
          when :facebook then value.gsub!(Canonicalized::FACEBOOK_PATTERN, '')
          when :phone then value.gsub!(Canonicalized::PHONE_PATTERN, '')
          end

          record.send("#{field}=", value)
        end
      end
    end
  end
end
