require 'spec_helper'

describe LocationDecorator do
  let(:context) { { center: [80.0, 80.0] } }
  describe '.instructor_color_ordinal' do
    context 'with nil instructor' do
      subject { build(:location).decorate }
      it 'returns open mat color ordinal' do
        subject.instructor_color_ordinal(nil).should eq LocationDecorator::OPEN_MAT_COLOR_ORDINAL
      end
    end
    context 'with instructor in location' do
      subject { create(:location_with_instructors).decorate }
      it 'returns the instructor index' do
        subject.instructor_color_ordinal(subject.instructors.first).should eq 0
        subject.instructor_color_ordinal(subject.instructors.last).should eq (subject.instructors.count-1)
      end
    end
    context 'with guest instructor' do
      subject { build(:location).decorate }
      it 'returns the guest instructor color ordinal' do
        subject.instructor_color_ordinal(build(:user)).should eq LocationDecorator::GUEST_INSTRUCTOR_COLOR_ORDINAL
      end
    end
  end
  describe '.contact_info?' do
    context 'when one of phone, email, website, facebook is present' do
      subject { build(:location, website: 'web').decorate }
      it 'is true' do
        subject.should be_contact_info
      end
    end
    context 'when phone, email, website, facebook are empty' do
      subject { build(:location, email: nil, website: nil, phone: nil, facebook: nil).decorate }
      it 'is false' do
        subject.should_not be_contact_info
      end
    end
  end
  describe '.facebook_group?' do
    context 'when facebook field is a group' do
      subject { build(:location, facebook: 'fb.com/groups/12345').decorate }
      it { subject.should be_facebook_group }
    end
    context 'when facebook field is not group' do
      subject { build(:location, facebook: 'fb.com/nubjj').decorate }
      it { subject.should_not be_facebook_group }
    end
    context 'when facebook field is nil' do
      subject { build(:location, facebook: nil).decorate }
      it { subject.should_not be_facebook_group }
    end
  end
  describe '.distance' do
    context 'when the context has a center point' do
      subject { build(:location).decorate(context: context) }
      before { Geocoder::Calculations.stub(:distance_between).and_return(123.0123) }
      it { subject.distance.should eq '123.01mi' }
    end
    context 'when the context has no center point' do
      subject { build(:location).decorate }
      it { subject.distance.should_not be_present }
    end
  end
  describe '.bearing' do
    context 'when the context has a center point' do
      let(:expected_bearing) { 123.0 }
      subject { build(:location).decorate(context: context) }
      before { Geocoder::Calculations.stub(:bearing_between).and_return(expected_bearing) }
      it { subject.bearing.should eq expected_bearing }
    end
    context 'when the context has no center point' do
      subject { build(:location).decorate }
      it { subject.bearing.should_not be_present }
    end
  end
  describe '.bearing_direction' do
    context 'when the context has a center point' do
      subject { build(:location).decorate(context: context) }
      let(:bearings) { [0.0, 45.0, 90.0, 135.0, 180.0, 225.0, 270, 315.0] }
      [:north, :'north-east', :east, :'south-east', :south, :'south-west', :west, :'north-west'].each_with_index do |direction, i|
        describe direction do
          before { Geocoder::Calculations.stub(:bearing_between).and_return(bearings[i]) }
          it { subject.bearing_direction.should eq direction }
        end
      end
    end
    context 'when the context has no center point' do
      subject { build(:location).decorate }
      it { subject.bearing_direction.should_not be_present }
    end
  end
  describe '.description' do
    context 'with blank description' do
      subject { build(:location, description: nil).decorate }
      it { subject.description.should match subject.title }
    end
    context 'with explicit description' do
      subject { build(:location, description: 'xyz').decorate }
      it { subject.description.should eq subject.object.description }
    end
  end
  describe '.image' do
    context 'with no image' do
      context 'with no team image' do
        subject { build(:location, image: nil, team: nil).decorate }
        it 'returns the avatar service image' do
          subject.image.should match("/service/avatar/100x100/#{subject.title}/image.png")
        end
        it 'escapes the title and replaces forward slashes' do
          subject.title = 'Test/Name'
          subject.image.should match("/service/avatar/100x100/Test+Name/image.png")
        end
      end
      context 'with team image' do
        subject do
          team = build(:team, image: '123.jpg')
          build(:location, image: nil, team: team).decorate
        end
        it 'returns the team image' do
          subject.image.should match(subject.object.team.image)
        end
      end
    end
    context 'with explicit image' do
      subject { build(:location, image: 'xyz.jpg').decorate }
      it 'returns the image' do
        subject.image.should match(subject.object.image)
      end
    end
  end
end
