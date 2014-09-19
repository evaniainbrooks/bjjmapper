require 'spec_helper'

describe LocationDecorator do
  describe '.description' do
    context 'with blank description' do
      subject { build(:location, description: nil).decorate }
      it { subject.description.should match LocationDecorator::DEFAULT_DESCRIPTION }  
    end
    context 'with explicit description' do
      subject { build(:location, description: 'xyz').decorate }
      it { subject.description.should eq subject.object.description }
    end
  end
end
