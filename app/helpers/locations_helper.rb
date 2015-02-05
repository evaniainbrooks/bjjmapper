module LocationsHelper
  def country_name_for(country)
    return '' unless country.present?
    country.length == 2 ? (RollFindr::DirectoryCountries.key(country) || country) : country
  end
end
