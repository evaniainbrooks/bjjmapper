require 'spec_helper'

describe LocationsHelper do
  describe '#country_name_for' do
    context 'when the country is nil' do
      it 'returns empty string' do
        helper.country_name_for(nil).should be_empty
      end
    end
    context 'when the country is not nil' do
      context 'when the country is a 2 char abbreviation' do
        context 'when the abbreviation is known' do
          it 'returns the mapped country name' do
            helper.country_name_for('DE').should eq 'Germany'
          end
        end
        context 'when the abbreviation is not known' do
          it 'returns the abbreviation' do
            helper.country_name_for('XX').should eq 'XX'
          end
        end
      end
      context 'when the country is a name' do
        it 'returns the country name verbatim' do
          helper.country_name_for('Canada').should eq 'Canada'
        end
      end
    end
  end
end
