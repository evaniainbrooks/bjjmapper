require 'spec_helper'

describe ReviewDecorator do
  describe '.attribution_name' do
    let(:expected_name) { 'Evan' }
    context 'without user' do
      subject { build_stubbed(:review, author_name: 'Evan', user: expected_name).decorate.attribution_name }
      it { should eq expected_name }
    end
    context 'with user' do
      let(:user) { build_stubbed(:user, name: expected_name) }
      subject { build_stubbed(:review, user: user, author_name: nil).decorate.attribution_name }
      it { should eq expected_name }
    end
  end
end
