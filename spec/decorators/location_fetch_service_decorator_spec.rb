require 'spec_helper'
require 'shared/locationfetchsvc_context'
require 'shared/websitestatussvc_context'

describe LocationFetchServiceDecorator do
  include_context 'websitestatus service'
  include_context 'locationfetch service'

  describe '.contact_info?' do
    context 'when one of phone, email, website, facebook is present' do
      subject { LocationFetchServiceDecorator.decorate(build(:location, website: 'web')) }
      xit 'is true' do
        subject.should be_contact_info
      end
    end
    context 'when phone, email, website, facebook are empty' do
      subject { LocationFetchServiceDecorator.decorate(build(:location, email: nil, website: nil, phone: nil, facebook: nil)) }
      it 'is false' do
        subject.should_not be_contact_info
      end
    end
  end
end
