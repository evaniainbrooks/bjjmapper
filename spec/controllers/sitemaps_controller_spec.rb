require 'spec_helper'
require 'shared/tracker_context'

describe SitemapsController do
  include_context 'skip tracking'
  describe 'GET index' do
    context 'with xml format' do
      it 'returns the sitemap' do
        get :index, format: 'xml'
        response.should be_ok
      end
    end
  end
end
