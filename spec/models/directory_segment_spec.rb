require 'spec_helper'

describe DirectorySegment do
  it 'has a factory' do
    build(:directory_segment).should be_valid
  end

  describe '.editable_by?' do
    subject { build(:directory_segment) }
    context 'when the editor is a super user' do
      let(:editor) { build(:user, role: 'super_user') }
      it { subject.editable_by?(editor).should be true }
    end

    context 'when the editor is not a super user' do
      let(:editor) { build(:user, role: 'user') }
      it { subject.editable_by?(editor).should be false }
    end
  end

  describe '.locations' do
    context 'when it is a child' do
      subject { build(:directory_segment, parent_segment: build(:directory_segment)) }
      before { Location.should_receive(:near).with(subject.coordinates, subject.distance) }
      it 'selects locations near the coordinates' do
        subject.locations
      end
    end
    context 'when it is a parent' do
      subject { build(:directory_segment, abbreviations: ['CAN', 'CA']) }
      before do
        Location.should_receive(:where) #.with(hash_including({country: subject.abbreviations}))
      end
      it 'selects locations with the country abbreviation' do
        subject.locations
      end
    end
  end

  describe '#for' do
    let(:city) { 'Halifax' }
    let(:country) { 'Canada' }
    let(:criteria) { { country: country, city: city } }
    context 'when the city and country do not exist' do
      subject { DirectorySegment.for(criteria) }
      it 'returns synthetic segments for both' do
        subject.parent_segment.should be_synthetic
        subject.should be_synthetic
      end
      xit 'the country has abbreviations' do
        subject.parent_segment.abbreviations.should_not be_empty
      end
    end
    context 'when the city does not exist' do
      before { create(:directory_segment, name: country) }
      subject { DirectorySegment.for(criteria) }
      it 'returns a synthetic segment for the city' do
        subject.parent_segment.should_not be_synthetic
        subject.should be_synthetic
      end
    end

    context 'when the city and country exist' do
      before do
        parent = create(:directory_segment, name: country)
        create(:directory_segment, name: city, parent_segment: parent)
      end
      subject { DirectorySegment.for(criteria) }
      it 'returns the segments' do
        subject.parent_segment.name.should eq country
        subject.parent_segment.should_not be_synthetic

        subject.name.should eq city
        subject.should_not be_synthetic
      end
    end
  end
end
