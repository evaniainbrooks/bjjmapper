require 'spec_helper'
require 'wikipedia'

describe User do
  describe '#from_omniauth' do
    let(:auth_params) { { 'provider' => 'google', 'uid' => '12345', 'info' => { 'name' => 'testname', 'email' => 'testemail' } } }
    let(:ip_addr) { '192.168.1.1' }
    context 'when the user does not exist' do
      subject { described_class.from_omniauth(auth_params, ip_addr) }
      it 'creates a new user' do
        expect {
          subject.name
        }.to change { User.count }.by(1)
      end
      it { subject.name.should eq auth_params['info']['name'] }
      it { subject.email.should eq auth_params['info']['email'] }
      it { subject.uid.should eq auth_params['uid'] }
      it { subject.ip_address.should eq ip_addr }
      it { subject.last_seen_at.should be_present }
    end
    context 'when the user exists' do
      let(:user) { create(:user, :uid => auth_params['uid'], :provider => auth_params['provider']) }
      subject { described_class.from_omniauth(auth_params, ip_addr) }
      it 'returns the user' do
        user
        subject.id.should eq user.id
      end
    end
  end

  describe 'before_create callback' do
    context 'when the role is instructor' do
      # TODO Refactor into shared context
      let (:img) { 'test_img.jpg' }
      let (:content) { 'test content' }
      before do
        page = double("wikipedia content")
        page.stub(:content) { content }
        page.stub(:image_urls) { [img] }
        Wikipedia.stub(:find).and_return(page)
      end
      subject { create(:user, :role => :instructor) }
      it 'populates description, summary and image from wikipedia' do
        subject.description.should eq content
        subject.image.should match img
        subject.description_src.to_sym.should eq :wikipedia
      end
    end
  end
end
