require 'spec_helper'

describe Map do
  context 'with no parameters' do
    subject { Map.new }
    it 'has defaults' do
      subject.zoom.should eq Map::ZOOM_DEFAULT
      subject.minZoom.should eq Map::DEFAULT_MIN_ZOOM
      subject.geolocate.should eq 1
    end
  end
  context 'with parameters' do
    let(:zoom) { 5 }
    let(:center) { [122.0, 45.0] }
    let(:minZoom) { 3 }
    let(:geolocate) { 0 }
    let(:location) { 'kuzey kibris' }
    let(:query) { 'near east university' }
    subject do
      Map.new(:zoom => zoom,
              :minZoom => minZoom,
              :geolocate => geolocate,
              :location => location,
              :query => query,
              :lat => center[0],
              :lng => center[1])
    end
    it 'has zoom, minZoom, geolocate and center params' do
      subject.zoom.should eq zoom
      subject.minZoom.should eq minZoom
      subject.geolocate.should eq geolocate
      subject.lat.should eq center[0]
      subject.lng.should eq center[1]
      subject.location.should eq location
      subject.query.should eq query
    end
  end
end
