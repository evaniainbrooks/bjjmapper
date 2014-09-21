require 'spec_helper'

describe LocationDecorator do
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
        subject { build(:location, image: nil, team: build(:team, image: '123.jpg')).decorate }
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
