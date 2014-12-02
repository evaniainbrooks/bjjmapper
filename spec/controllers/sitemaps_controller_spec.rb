require 'spec_helper'

describe SitemapsController do
  describe 'GET index' do
    context 'with xml format' do
      it 'returns the sitemap' do
        get :index, format: 'xml'
        response.should be_ok
      end
    end
  end
end
