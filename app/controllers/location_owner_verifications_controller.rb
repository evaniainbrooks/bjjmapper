class LocationOwnerVerificationsController < ApplicationController
  before_action :ensure_signed_in, only: [:create]

  before_action :set_location, only: [:create]
  before_action :set_verification_object, only: [:verify]

  def create
    tracker.track('createLocationOwnerVerification',
      owner: current_user,
      location: @location.to_param
    )

    @verification = LocationOwnerVerification.create(
      :location => @location,
      :user => current_user
    )

    head :created
  end

  def verify
    tracker.track('verifyLocationOwner',
      owner: @verification.user.to_param,
      location: @verification.location.to_param
    )

    @verification.location.update_attribute(:owner, @verification.user)
    redirect_to location_path(@verification.location, claimed: 1)
  end

  private

  def set_location
    location_id = params.fetch(:location_id, nil)
    head :bad_request and return false unless location_id.present?

    @location = Location.find(location_id)
    head :not_found and return false unless @location.present?
  end

  def set_verification_object
    token = params.fetch(:id, nil)
    head :bad_request and return false unless token.present?

    @verification = LocationOwnerVerification.with_token(token).first
    head :not_found and return false unless @verification.present?
  end
end

