require 'spec_helper'

describe TeamDecorator do
  describe '.image' do
    context 'with explicit image' do
      subject { build(:team, image: 'xyz.jpg').decorate }
      it 'returns the image' do
        subject.image.should match(subject.object.image)
      end
    end
  end
  describe '.description' do
    context 'with blank description' do
      subject { build(:team, description: nil).decorate }
      it { subject.description.should match TeamDecorator::DEFAULT_DESCRIPTION }
    end
    context 'with explicit description' do
      subject { build(:team, description: 'xyz').decorate }
      it { subject.description.should eq subject.object.description }
    end
  end
end
