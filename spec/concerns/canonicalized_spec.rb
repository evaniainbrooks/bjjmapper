require 'spec_helper'

describe Canonicalized do
  let(:facebook_value) { 'eibjj' }
  let(:test_class) do
    Class.new do
      include Mongoid::Document
      include Canonicalized

      store_in collection: 'tests'
      field :facebook, type: String
      canonicalize :facebook, as: :facebook
    end
  end
  subject { test_class.new(:facebook => "http://www.facebook.com/#{facebook_value}") }
  before { subject.save }

  it 'cleans the facebook value' do
    subject.facebook.should eq facebook_value
  end
end

