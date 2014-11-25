require 'spec_helper'
require 'analyzable'
require 'analyzable_robot_properties'

describe RollFindr::AnalyzableRobotProperties do
  include RollFindr::Analyzable
  include RollFindr::AnalyzableRobotProperties

  def request
    OpenStruct.new(env: { 'HTTP_USER_AGENT' => 'Robot (http://www.google.com) ' })
  end

  def current_user
    OpenStruct.new(internal: false)
  end

  it 'sets the is_robot analytics super property' do
    analytics_super_properties.should be_a(Hash)
    analytics_super_properties[:is_robot].should be_truthy
  end
end
