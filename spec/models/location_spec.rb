require 'spec_helper'

describe Location do
  it 'has a factory' do
    build(:location).should be_valid
  end

  it 'has a decorator' do
    Location.new.decorate.should be_decorated
  end

  describe '.editable_by?' do
    context 'when the editor is a super user' do
      let(:editor) { build(:user, role: 'super_user') }
      subject { build(:location) }
      it { subject.editable_by?(editor).should be true }
    end
    context 'when editor not superuser' do
      context 'when closed or moved' do
        subject { build(:location, flag_closed: true) }
        let(:editor) { build(:user, role: 'user') }
        it { subject.editable_by?(editor).should be false }
      end
      context 'when anonymous' do
        subject { build(:location) }
        let(:editor) { build(:user, role: 'anonymous') }
        it { subject.editable_by?(editor).should be false }
      end
      context 'when not anonymous' do
        context 'when claimed and the editor is not the owner' do
          subject { build(:location) }
          before { subject.stub(:owner).and_return(double(id: 1234)) }
          let(:editor) { build(:user, role: 'user') }
          it { subject.editable_by?(editor).should be false }
        end
        context 'when not claimed' do
          subject { build(:location, owner: nil) }
          let(:editor) { build(:user, role: 'user') }
          it { subject.editable_by?(editor).should be true }
        end
        context 'when claimed and the editor is the owner' do
          subject { build(:location) }
          let(:editor) { build(:user, role: 'user') }
          before do
            subject.stub(:owner).and_return(double(id: 1234))
            editor.stub(:id).and_return(1234)
          end
          it { subject.editable_by?(editor).should be true }
        end
      end
    end
  end

  describe '.schedule' do
    subject { create(:location) }
    before { LocationSchedule.should_receive(:new).with(subject.id) }
    it 'lazy initializes the LocationSchedule with our id' do
      subject.schedule
    end
  end
  describe '.ig_hashtag' do
    context 'without an explicit value' do
      context 'without a team' do
        subject { build(:location, title: 'Instagram Test', team: nil, ig_hashtag: nil) }
        it 'returns the default hashtag' do
          subject.ig_hashtag.should eq 'bjjmapperinstag'
        end
      end
      context 'with a team' do
        let(:team) { create(:team) }
        subject { build(:location, title: 'Instagram Test', team: team, ig_hashtag: nil) }
        it 'returns the teams hashtag' do
          subject.ig_hashtag.should eq team.ig_hashtag
        end
      end
    end
    context 'with an explicit value' do
      subject { build(:location, title: 'Instagram Test', ig_hashtag: 'explicitvalue') }
      it 'returns the explicit value' do
        subject.ig_hashtag.should eq 'explicitvalue'
      end
    end
  end

  describe '.as_json' do
    it 'returns the object as json' do
      json = build(:location).as_json({})
      [:id, :team_id, :coordinates, :team_name, :address].each {|x| json.should have_key(x) }
    end
  end

  describe '.timezone' do
    context 'when the timezone service returns a response' do
      let(:expected_timezone) { 'Some/Timezone' }
      before { RollFindr::TimezoneService.stub(:timezone_for).and_return(expected_timezone) }
      context 'when the field is empty and there are coordinates' do
        subject { build(:location, coordinates: [80.0, 80.0], timezone: nil) }
        it 'populates the field' do
          subject.timezone.should eq expected_timezone
        end
      end
      context 'when the field is not empty and the coordinates changed' do
        subject { build(:location, coordinates: [80.0, 80.0], timezone: 'Change/ThisPlease') }
        before { subject.coordinates = [81.0, 81.0] }
        it 'repopulates the field with the new timezone' do
          subject.timezone.should eq expected_timezone
        end
      end
    end
    context 'when the timezone service raises an error' do
      before { RollFindr::TimezoneService.stub(:timezone_for).and_raise(StandardError.new) }
      let(:previous_value) { 'some/timezone' }
      subject { build(:location, coordinates: [80.0, 80.0], timezone: previous_value) }
      before do 
        subject.save
        subject.update_attribute(:timezone, previous_value)
      end
      it 'rescues and retains previous value' do
        subject.timezone.should eq previous_value
        subject.should be_persisted
      end
    end
  end

  describe '.title' do
    context 'when event venue' do
      it 'returns a generated title when it is missing' do
        build(:event_venue, title: nil).save.title.should_not be_blank
      end
    end
    context 'when academy' do
      it 'is invalid when blank' do
        build(:location, title: nil).should_not be_valid
      end
    end
  end

  describe 'flag_closed' do
    context 'when moved_to_location is present' do
      let(:moved_to) { create(:location) }
      subject { build(:location, flag_closed: false, moved_to_location: moved_to) }
      before { subject.save }
      it 'is automatically set' do
        subject.flag_closed.should eq true
      end
    end
    context 'when moved_to_location is blank' do
      subject { build(:location, flag_closed: false, moved_to_location: nil) }
      before { subject.save }
      it 'is unchanged' do
        subject.flag_closed.should eq false
      end
    end
  end

  describe 'flag_has_black_belt' do
    context 'when the instructors relation has a black belt' do
      subject { build(:location) }
      let(:bb) { build(:black_belt) }
      before do
        subject.instructors << bb
        subject.save
      end
      it 'is true' do
        subject.flag_has_black_belt.should eq true
      end
    end
    context 'when the instructors relation has no black belt' do
      subject { build(:location) }
      let(:pb) { build(:purple_belt) }
      before do
        subject.instructors << pb
        subject.save
      end
      it 'is false' do
        subject.flag_has_black_belt.should eq false
      end
    end
  end


  describe 'before save callback' do
    subject { build(:location, phone: '(902)', website: 'http://test.com', facebook: 'http://www.facebook.com/page') }
    before { subject.save }
    it 'canonicalizes the phone number' do
      subject.phone.should eq '902'
    end
    it 'canonicalizes the website' do
      subject.website.should eq 'test.com'
    end

    it 'canonicalizes the facebook page' do
      subject.facebook.should eq 'page'
    end
  end
end
