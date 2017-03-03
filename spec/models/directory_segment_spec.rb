require 'spec_helper'
require 'shared/locationfetchsvc_context'

describe DirectorySegment do
  include_context 'locationfetch service'

  it 'has a factory' do
    build_stubbed(:directory_segment).should be_valid
  end

  describe '.editable_by?' do
    subject { build_stubbed(:directory_segment) }
    context 'when the editor is a super user' do
      let(:editor) { build_stubbed(:user, role: 'super_user') }
      it { subject.editable_by?(editor).should be true }
    end

    context 'when the editor is not a super user' do
      let(:editor) { build_stubbed(:user, role: 'user') }
      it { subject.editable_by?(editor).should be false }
    end
  end

  describe '.locations' do
    context 'when it is a child' do
      subject { build_stubbed(:directory_segment, parent_segment: build_stubbed(:directory_segment)) }
      before do
        Location.should_receive(:where) { Location }
      end
      it 'selects locations near the coordinates' do
        subject.locations
      end
    end
    context 'when it is a parent' do
      subject { build_stubbed(:directory_segment, abbreviations: ['CAN', 'CA']) }
      before do
        Location.should_receive(:where) { Location }
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
      it 'the country has abbreviations' do
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
