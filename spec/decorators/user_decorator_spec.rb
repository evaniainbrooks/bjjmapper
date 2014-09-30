require 'spec_helper'

describe UserDecorator do
  describe '.belt_rank' do
    context 'with explicit rank' do
      subject { build(:user, belt_rank: 'blue').decorate }
      it 'returns the rank' do
        subject.belt_rank.should eq subject.object.belt_rank
      end
    end
    context' with missing rank' do
      subject { build(:user, belt_rank: nil).decorate }
      it 'returns white' do
        subject.belt_rank.should eq 'white'
      end
    end
  end
  describe '.stripe_rank' do
    context 'with explicit rank' do
      subject { build(:user, stripe_rank: 5).decorate }
      it 'returns the rank' do
        subject.stripe_rank.should eq subject.object.stripe_rank
      end
    end
    context' with missing rank' do
      subject { build(:user, stripe_rank: nil).decorate }
      it 'returns 0' do
        subject.stripe_rank.should eq 0
      end
    end
  end
  describe '.rank_image' do
    let(:no_rank) { build(:user, belt_rank: nil, stripe_rank: nil).decorate }
    let(:blue) { build(:user, belt_rank: 'blue', stripe_rank: 2).decorate }
    let(:black) { build(:user, belt_rank: 'black', stripe_rank: 4).decorate }
    it 'returns the belt image' do
      no_rank.rank_image.should match("belts/white0.png")
      blue.rank_image.should match("belts/blue2.png")
      black.rank_image.should match("belts/black4.png")
    end
  end
  describe '.image' do
    context 'with no image' do
      subject { build(:user, image: nil).decorate }
      it 'returns the default image' do
        subject.image.should match(UserDecorator::DEFAULT_IMAGE)
      end
    end
    context 'with explicit image' do
      subject { build(:user, image: 'xyz.jpg').decorate }
      it 'returns the image' do
        subject.image.should match(subject.object.image)
      end
    end
  end
end
