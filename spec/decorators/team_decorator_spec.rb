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
end
