require 'analyzable'

module RollFindr
  module AnalyzableRobotProperties

    protected

    def analytics_super_properties
      props = {
        is_robot: request_is_robot?
      }
      defined?(super) ? super.merge(props) : props
    end

    private

    def request_is_robot?
      request.env['HTTP_USER_AGENT'].try(:match, /\(.*https?:\/\/.*\)|Wget|Bot|Robot/).present?
    end
  end
end
