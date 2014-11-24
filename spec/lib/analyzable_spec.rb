require 'spec_helper'
require 'analyzable'

describe RollFindr::Analyzable do
  let(:ua_string) { 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36' }
  let(:user) { OpenStruct.new(id: 123) }
  let(:accept_language) { 'en' }
  let(:ref) { 'testref' }
  let(:test_class) do
    Class.new do
      include RollFindr::Analyzable
      def current_user; OpenStruct.new(id: 123); end
      def request; OpenStruct.new(user_agent: 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36', env: { 'HTTP_ACCEPT_LANGUAGE' => 'en' }); end
      def params; { ref: 'testref' }; end
    end
  end
  let(:ua_parser) { Agent.new(ua_string) }

  subject { test_class.new }
  before do
    RollFindr::Tracker.should_receive(:new).with(
      user.to_param,
      hash_including(
        browser_name: ua_parser.name,
        browser_version: ua_parser.version,
        browser_engine: ua_parser.engine,
        browser_os: ua_parser.os,
        browser_engine_version: ua_parser.engine_version,
        user_agent: ua_string,
        accept_language: accept_language,
        ref: ref
      )
    )
  end
  it 'has a tracker' do
    subject.send(:tracker)
  end
end
