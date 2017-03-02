module LocationsHelper
  def format_address addr
    addr.split(',',2).join(tag(:br)).html_safe
  end

  def upload_image_location_path(location)
    "/service/avatar/upload/locations/#{location.id}/async"
  end
  
  def country_name_for(country)
    return '' unless country.present?
    return RollFindr::DirectoryCountryAbbreviations[country] || country
  end
end
