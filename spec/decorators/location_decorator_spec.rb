require 'spec_helper'

describe LocationDecorator do
  let(:context) { { center: [80.0, 80.0] } }
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
      it { subject.description.should match LocationDecorator::DEFAULT_DESCRIPTION }
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
        it 'returns the default image' do
          subject.image.should match(LocationDecorator::DEFAULT_IMAGE)
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
