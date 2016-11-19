require 'spec_helper'

describe Canonicalized do
  let(:facebook_value) { 'eibjj' }
  let(:phone_value) { '+905428788488' }
  let(:test_class) do
    Class.new do
      include Mongoid::Document
      include Canonicalized

      store_in collection: 'tests'
      field :facebook, type: String
      field :phone, type: String
      canonicalize :facebook, as: :facebook
      canonicalize :phone, as: :phone
    end
  end
  subject { test_class.new(:facebook => "http://www.facebook.com/pg/#{facebook_value}", :phone => "abcd(#{phone_value}k&%#(@") }
  before { subject.save }

  it 'cleans the facebook value' do
    subject.facebook.should eq facebook_value
    subject.phone.should eq phone_value
  end
end

