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
    subject do
      Map.new(:zoom => zoom, :minZoom => minZoom, :geolocate => geolocate, :center => center)
    end
    it 'has zoom, minZoom, geolocate and center params' do
      subject.zoom.should eq zoom
      subject.minZoom.should eq minZoom
      subject.geolocate.should eq geolocate
      subject.center.should eq center
    end
  end
end
