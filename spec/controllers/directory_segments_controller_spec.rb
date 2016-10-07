require 'spec_helper'

describe DirectorySegmentsController do
  describe 'GET index' do
    before do
      create(:directory_segment, name: 'Greece')
      create(:directory_segment, name: 'Cyprus')
    end
    it 'fetches all parent segments' do
      get :index, format: 'html'
      response.status.should eq 200

      assigns[:directory_segments].should eq DirectorySegment.parent_segments
    end
  end
  describe 'GET show' do
    context 'with country and city criteria' do
      let(:criteria) { { :city => 'New York', :country => 'US' } }
      it 'fetches the directory segments' do
        get :show, criteria
        response.status.should eq 200

        assigns[:directory_segment].name.should eq criteria[:city]
        assigns[:directory_segment].parent_segment.name.should eq criteria[:country]
      end
    end
    context 'with country criteria' do
      let(:criteria) { { :country => 'US' } }
      it 'fetches the directory segments' do
        get :show, criteria
        response.status.should eq 200

        assigns[:directory_segment].name.should eq criteria[:country]
        assigns[:directory_segment].parent_segment.should be_nil
      end
    end
  end
end
