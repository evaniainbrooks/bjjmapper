module LocationsHelper
  def country_name_for(country)
    return '' unless country.present?
    return RollFindr::DirectoryCountryAbbreviations[country] || country
  end
  
  def location_create_params
    p = params.require(:location).permit(*Location::CREATE_PARAMS_WHITELIST)
    p[:coordinates] = JSON.parse(p[:coordinates]) if p[:coordinates].present?
    p[:modifier] = current_user if signed_in?
    p
  end
end
