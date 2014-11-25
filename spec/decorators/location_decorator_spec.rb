require 'spec_helper'

describe LocationDecorator do
  describe '.distance' do
    context 'when the context has a center point' do
      let(:context) { { center: [80.0, 80.0] } }
      subject { build(:location).decorate(context: context) }
      before { Geocoder::Calculations.stub(:distance_between).and_return(123.0123) }
      it { subject.distance.should eq '123.01mi' }
    end
    context 'when the context has no center point' do
      subject { build(:location).decorate }
      it { subject.distance.should_not be_present } 
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
