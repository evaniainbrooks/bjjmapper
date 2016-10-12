require 'spec_helper'

describe MapLocationDecorator do
  let(:default_params) { { context: { location_type: [] } } }
  def params(p)
    return default_params.deep_merge(context: p)
  end

  describe '.image' do
    context 'when academy' do
      let(:img) { 'someimg' }
      let(:location) { build(:location, image: img) }
      subject { MapLocationDecorator.decorate(location, default_params) }
      it 'is the image of the academy' do
        # FIXME: Underlying decorator uses image_path
        subject.image.should eq "/images/#{img}"
      end
    end
    context 'with events' do
      let(:img) { 'someimg' }
      let(:event_venue) { build(:event_venue) }
      let(:organization) { build(:organization, image: img) }
      let(:event) { build(:event, location: event_venue, organization: organization) }
      subject { MapLocationDecorator.decorate(event_venue, params({ events: [event] })) }
      it 'is the image of the first event' do
        subject.image.should eq img
      end
    end
  end

  describe '.title' do
    context 'when there is 1 event' do
      let(:title) { 'some title' }
      let(:event_venue) { build(:event_venue) }
      let(:event) { build(:event, location: event_venue, title: title) }
      subject { MapLocationDecorator.decorate(event_venue, params({ events: [event] })) }
      it 'is the title of the first event' do
        subject.title.should eq title
      end
    end
    context 'when there are multiple events' do
      let(:event_venue) { build(:event_venue) }
      let(:events) { [build(:event, location: event_venue), build(:event, location: event_venue)] } 
      subject { MapLocationDecorator.decorate(event_venue, params({ events: events })) }
      it 'is a string containing the event count' do
        subject.title.should match('2')
      end
    end
    context 'when it is an academy' do
      let(:academy) { build(:location) }
      subject { MapLocationDecorator.decorate(academy, default_params) }
      it 'is the title of the academy' do
        subject.title.should eq academy.title
      end
    end
  end
  describe '.entities' do
    context 'with events' do
      let(:events) {
        [build(:tournament, organization: build(:organization)), build(:seminar, instructor: build(:user), organization: nil)]
      }

      subject { MapLocationDecorator.decorate(build(:location), params({events: events})) }
      it 'returns a sentence with the instructor and organization names' do
        subject.entities.should match events[0].organization.name
        subject.entities.should match events[1].instructor.name
      end
    end
    context 'without events' do
      subject { MapLocationDecorator.decorate(build(:location)).entities }
      it { should be_nil }
    end
  end
  describe 'loctype' do
    context 'when the academy has events and the filter does not contain academies' do
      let(:location) { build(:location, loctype: Location::LOCATION_TYPE_ACADEMY) }
      let(:filter) { [Location::LOCATION_TYPE_EVENT_VENUE] }
      let(:event) { build(:event) }
      subject { MapLocationDecorator.decorate(location, params({ location_type: filter, events: [event] })) }
      it 'acts as event venue' do
        subject.loctype.should eq Location::LOCATION_TYPE_EVENT_VENUE
      end
    end
    it { build(:location, loctype: Location::LOCATION_TYPE_ACADEMY).decorate.loctype.should eq Location::LOCATION_TYPE_ACADEMY }
  end
  describe 'link' do
    context 'when academy' do
      let(:location) { create(:location) }
      subject { MapLocationDecorator.decorate(location, default_params) }
      it 'is the academy path' do
        subject.link.should match(location_path(location, ref: 'map_item'))
      end
    end
    context 'with 1 event' do
      let(:location) { create(:location) }
      let(:event) { create(:event, location: location) }
      subject { MapLocationDecorator.decorate(location, params({events: [event]})) }
      it 'is the academy path' do
        subject.link.should match(location_event_path(location, event, ref: 'map_item'))
      end
    end
    context 'with many events' do
      let(:location) { create(:location) }
      let(:events) { [build(:event), build(:event)] }
      subject { MapLocationDecorator.decorate(location, params({events: events})) }
      it 'is the academy path' do
        subject.link.should match(schedule_location_path(location, ref: 'map_item'))
      end
    end
  end
end
