class LocationStatusesController < ApplicationController
  include LocationsHelper

  before_action :set_location
  before_action :ensure_signed_in
  before_action :check_permissions

  decorates_assigned :location

  def pending
    tracker.track('setStatusPendingLocation',
      location: @location.to_param
    )

    @location.update_attributes(status: Location::STATUS_PENDING, status_updated_at: Time.now, modifier: current_user)

    render status: :accepted, json: {}
  end

  def reject
    tracker.track('setStatusRejectLocation',
      location: @location.to_param
    )

    @location.update_attributes(status: Location::STATUS_REJECTED, status_updated_at: Time.now, modifier: current_user)

    render status: :accepted, json: {}
  end

  def verify
    tracker.track('setStatusVerifyLocation',
      location: @location.to_param
    )

    if (@location.status != Location::STATUS_VERIFIED)
      Rails.logger.debug("Searching metadata for #{@location.to_param}")
      @location.update_attributes(status: Location::STATUS_VERIFIED, status_updated_at: Time.now, modifier: current_user)
      @location.search_metadata!
    end

    render status: :accepted, json: {}
  end
  
  private

  def set_location
    id_param = params.fetch(:location_id, '')
    @location = Location.find(id_param)

    head :not_found and return false unless @location.present?
  end

  def check_permissions
    head :forbidden and return false unless current_user.can_edit?(@location)
  end
end
