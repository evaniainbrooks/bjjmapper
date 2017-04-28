require 'spec_helper'
require 'wikipedia'
require 'shared/locationfetchsvc_context'

describe User do
  include_context 'locationfetch service'

  it 'has a factory' do
    build_stubbed(:user).should be_valid
  end
  describe 'validations' do
    describe '.name' do
      it 'is invalid without a name' do
        build_stubbed(:user, name: 'hello world').should be_valid
        build_stubbed(:user, name: nil).should_not be_valid
      end
    end
    describe '.image, .image_tiny, .image_large' do
      xit 'must have a valid prefix' do
        build_stubbed(:user, image: 'https://commondatastorage.googleapis.com/bjjmapper/test.png').should be_valid
        build_stubbed(:user, image: 'hacks.com/test.png').should_not be_valid
      end
    end
  end
  describe '#jitsukas' do
    before do
      create(:user, name: 'included', belt_rank: 'black')
      create(:user, name: 'excluded', belt_rank: 'white')
    end
    it 'returns only users with a rank' do
      User.jitsukas.count.should eq 1
      User.jitsukas.first.name.should eq 'included'
    end
  end
  describe '#anonymous' do
    let(:ip_addr) { '192.168.1.1' }
    context 'when geocoding succeeds' do
      it 'creates a new anonymous user' do
        expect do
          anon_user = described_class.anonymous(ip_addr)
          anon_user.should be_anonymous
        end.to change { User.count }.by(1)
      end
    end
    context 'when geocoding fails' do
      before do
        Geocoder.stub(:search).and_raise(StandardError)
      end
      it 'creates a new anonymous user' do
        expect do
          anon_user = described_class.anonymous(ip_addr)
          anon_user.should be_anonymous
        end.to change { User.count }.by(1)
      end
    end
  end
  describe '#from_omniauth' do
    let(:auth_params) { { 'provider' => 'google', 'uid' => '12345', 'info' => { 'name' => 'testname', 'email' => 'testemail' } } }
    let(:ip_addr) { '192.168.1.1' }
    context 'when the user does not exist' do
      subject { described_class.from_omniauth(auth_params, ip_addr) }
      it 'initializes a new user' do
        expect do
          subject.name
          subject.should be_new_record
        end.to change { User.count }.by(0)
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

  describe '.birthdate' do
    context 'with invalid date' do
      subject { build_stubbed(:user).birthdate }
      before { Date.stub(:new).and_raise('an error') }
      it 'returns nil' do
        subject.should be_nil
      end
    end
    context 'with valid date' do
      subject { build_stubbed(:user, birth_day: 24, birth_month: 9, birth_year: 1986).birthdate }
      it 'returns a date object' do
        subject.should be_kind_of(Date)
      end
    end
  end

  describe '.editable_by?' do
    context 'when the editor is a super user' do
      let(:editor) { build_stubbed(:user, role: 'super_user') }
      subject { build_stubbed(:user, role: 'user') }
      it { subject.editable_by?(editor).should be true }
    end
    context 'when the editor is not a super user' do
      context 'when anonymous' do
        subject { build_stubbed(:user, role: 'user') }
        let(:editor) { build_stubbed(:user, role: 'anonymous') }
        it { subject.editable_by?(editor).should be false }
      end
      context 'when not anonymous' do
        context 'when locked and the user and editor are not the same' do
          subject { build_stubbed(:user, role: 'user', flag_locked: true, provider: '123') }
          let(:editor) { build_stubbed(:user, role: 'user') }
          before do
            subject.stub(:id).and_return(999)
            editor.stub(:id).and_return(1)
          end
          it { subject.editable_by?(editor).should be false }
        end
        context 'when not locked' do
          subject { build_stubbed(:user, role: 'user', provider: nil) }
          let(:editor) { build_stubbed(:user, role: 'user') }
          it { subject.editable_by?(editor).should be true }
        end
        context 'when the user and editor are the same' do
          let(:editor) { build_stubbed(:user, role: 'user') }
          it { editor.editable_by?(editor).should be true }
        end
      end
    end
  end

  describe '.jitsuka?' do
    context 'when the user has a rank' do
      subject { build_stubbed(:user, belt_rank: 'white') }
      it { subject.should be_jitsuka }
    end
    context 'when the user does not have a rank' do
      subject { build_stubbed(:user, belt_rank: nil) }
      it { subject.should_not be_jitsuka }
    end
  end
  describe '.anonymous?' do
    it 'returns false when not anonymous' do
      build_stubbed(:user, role: 'bogus').should_not be_anonymous
    end
    it 'returns true when anonymous' do
      build_stubbed(:user, role: 'anonymous').should be_anonymous
    end
  end
  describe '.full_lineage' do
    context 'when there is no lineal_parent' do
      it 'returns empty array' do
        build_stubbed(:user, lineal_parent: nil).full_lineage.should eq []
      end
    end
    context 'when there is a lineal_parent' do
      before do
        @a = create(:user, name: 'a')
        @b = create(:user, name: 'b', lineal_parent: @a)
      end
      let(:expected_names) { ['b', 'a'] }
      it 'returns a list of the ancestors' do
        create(:user, lineal_parent: @b).full_lineage.map(&:name).should eq expected_names
      end
    end
  end
  describe '#rank_sort_key' do
    let(:wb0) { build_stubbed(:user, stripe_rank: 0, belt_rank: 'white') }
    let(:wb1) { build_stubbed(:user, stripe_rank: 1, belt_rank: 'white') }
    let(:pb) { build_stubbed(:user, stripe_rank: 0, belt_rank: 'purple') }
    let(:bb) { build_stubbed(:user, stripe_rank: 0, belt_rank: 'black') }
    it 'returns a key that will sort a list of users by descending rank' do
      User.rank_sort_key(wb0.belt_rank, wb0.stripe_rank).should > User.rank_sort_key(wb1.belt_rank, wb1.stripe_rank)
      User.rank_sort_key(wb1.belt_rank, wb1.stripe_rank).should > User.rank_sort_key(pb.belt_rank, pb.stripe_rank)
      User.rank_sort_key(pb.belt_rank, pb.stripe_rank).should > User.rank_sort_key(bb.belt_rank, bb.stripe_rank)
    end
  end
  describe 'before_create callback' do
    context 'when the role is instructor' do
      # TODO Refactor into shared context
      let(:img) { 'test_img.jpg' }
      let(:content) { 'test content' }
      before do
        page = double("wikipedia content")
        page.stub(:content) { content }
        page.stub(:image_urls) { [img] }
        Wikipedia.stub(:find).and_return(page)
      end
      subject { create(:user, :role => :instructor) }
      xit 'populates description, summary and image from wikipedia' do
        subject.description.should eq content
        subject.image.should match img
        subject.description_src.to_sym.should eq :wikipedia
      end
    end
  end
end
