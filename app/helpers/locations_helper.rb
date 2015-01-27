module LocationsHelper
  def country_name_for(country)
    country.length == 2 ? (RollFindr::DirectoryCountries.index(country) || country) : country
  end
end
