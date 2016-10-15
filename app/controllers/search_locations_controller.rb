class SearchLocationsController < ApplicationController
  decorates_assigned :locations

  def show
    query = params.fetch(:query, '')

    head :bad_request and return false unless query.present?

    @geocoder_results = Geocoder.search(query)
    @locations = begin
      ids = Location.search_ids(query)
      Location.where(:_id.in => ids)
    end

    respond_to do |format|
      format.json do
        head :no_content and return unless @geocoder_results.present? || @locations.present?
        render
      end
    end
  end
end
