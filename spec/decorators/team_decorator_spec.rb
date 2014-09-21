require 'spec_helper'

describe TeamDecorator do
  describe '.image' do
    context 'with no image' do
      subject { build(:team, image: nil).decorate }
      it 'returns the default image' do
        pending
      end
    end
    context 'with explicit image' do
      subject { build(:team, image: 'xyz.jpg').decorate }
      it 'returns the image' do
        subject.image.should match(subject.object.image)
      end
    end
  end
end
