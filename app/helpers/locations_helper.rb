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
  
  def location_create_params
    p = params.require(:location).permit(*Location::CREATE_PARAMS_WHITELIST)
    
    if p[:coordinates].present? && p[:coordinates].instance_of?(String)
      p[:coordinates] = JSON.parse(p[:coordinates])
    end

    p[:modifier] = current_user if signed_in?
    p
  end
end
