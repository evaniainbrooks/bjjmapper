require 'spec_helper'
require 'analyzable'
require 'analyzable_user_super_properties'

describe RollFindr::AnalyzableUserSuperProperties do
  include RollFindr::Analyzable
  include RollFindr::AnalyzableUserSuperProperties
  
  let(:ua_string) { 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36' }
  let(:user) { OpenStruct.new(id: 123) }
  let(:ua_parser) { Agent.new(ua_string) }
  let(:accept_language) { 'en' }
  
  def request 
    OpenStruct.new(user_agent: ua_string, env: { 'HTTP_ACCEPT_LANGUAGE' => 'en' })
  end
  
  def params
    { ref: 'testref' }
  end
 
  let(:expected_properties) do
    {
      browser_name: ua_parser.name,
      browser_version: ua_parser.version,
      browser_engine: ua_parser.engine,
      browser_os: ua_parser.os,
      browser_engine_version: ua_parser.engine_version,
      user_agent: ua_string,
      accept_language: accept_language,
      ref: params[:ref]
    }
  end

  it 'sets the user agent analytics super properties' do
    analytics_super_properties.should include(expected_properties)
  end
end
