require 'active_support/concern'

module Canonicalized
  extend ActiveSupport::Concern

  module ClassMethods
    def canonicalize(field, options = {})
      before_save do |record|
        if record.send("#{field}_changed?")
          value = record.send(field)

          case options[:as] || field
          when :website then value.gsub!(/^https?:\/\//, '')
          when :facebook then value.gsub!(/(^https?:\/\/(www\.)?)|facebook\.com\/|fb\.com\//, '')
          when :phone then value.gsub!(/[^\d+]/, '')
          end

          record.send("#{field}=", value)
        end
      end
    end
  end
end
