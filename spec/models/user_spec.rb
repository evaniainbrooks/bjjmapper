require 'spec_helper'

describe User do
  describe '#create_with_omniauth' do
    let(:example_ip) { '192.168.1.1' }
    let(:example_auth) { { 'provider' => 'google', 'uid' => '12345', 'info' => { 'name' => 'testname', 'email' => 'testemail' } } }
    subject { described_class.create_with_omniauth(example_auth, example_ip) }
    its(:name) { should eq example_auth['info']['name'] }
    its(:email) { should eq example_auth['info']['email'] }
    its(:uid) { should eq example_auth['uid'] }
    its(:ip_address) { should eq example_ip }
  end
end
