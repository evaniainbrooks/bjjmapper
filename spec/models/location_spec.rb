require 'spec_helper'

describe Location do
  it 'has a factory' do
    build(:location).should be_present
  end

  it 'has a decorator' do
    Location.new.decorate.should be_decorated
  end

  describe '.as_json' do
    it 'returns the object as json' do
      json = build(:location).as_json({})
      [:id, :team_id, :instructors, :coordinates, :team_name, :address].each {|x| json.should have_key(x) }
    end
  end

  describe 'validations' do
    it 'is invalid without a title' do
      build(:location, title: nil).should_not be_valid
    end
  end


  describe 'before save callback' do
    subject { build(:location, phone: '(902)', website: 'http://test.com', facebook: 'http://www.facebook.com/page') }
    before { subject.save }
    it 'canonicalizes the phone number' do
      subject.phone.should eq '902'
    end
    it 'canonicalizes the website' do
      subject.website.should eq 'test.com'
    end

    it 'canonicalizes the facebook page' do
      subject.facebook.should eq 'page'
    end
  end
end
