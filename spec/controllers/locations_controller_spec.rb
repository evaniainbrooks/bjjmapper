require 'spec_helper'

describe LocationsController do
  describe '.show' do
    let(:create_params) {{ title: 'test', description: 'test', coordinates: [122.0, 40.0] }}
    context 'with json format' do 
      let(:location) { Location.create(create_params) } 
      it 'returns the location' do
        get :show, { format: 'json', id: location.id }
        response.body.should eq location.to_json
      end
    end
    context 'with html format' do
      let(:location) { Location.create(create_params) } 
      it 'returns the location markup' do
        get :show, { id: location.id }
        response.should render_template("locations/show")
      end
    end
  end

end
