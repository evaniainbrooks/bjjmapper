class GeocodersController < ApplicationController
  def show
    search_query = params.fetch(:query, '')
    @search_results = GeocodersHelper.search(search_query)

    tracker.track('geocodeQuery',
      query: search_query,
      result_count: @search_results.count
    )

    respond_to do |format|
      format.json do
        unless @search_results.count > 0
          render status: :not_found, json: {}
        end
      end
    end
  end
end

