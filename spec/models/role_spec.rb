require 'spec_helper'
require 'shared/locationfetchsvc_context'

describe Role do
  include_context 'locationfetch service'

  describe '#power' do
    context 'with role' do
      it 'returns 0' do
        Role.power(Role::READ_ONLY_USER).should_not eq 0
      end
    end
    context 'without known role' do
      it 'returns 0' do
        Role.power(nil).should eq 0
      end
    end
  end
end
