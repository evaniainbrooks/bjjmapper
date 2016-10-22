class LocationOwnerVerificationsController < ApplicationController
  before_action :ensure_signed_in, only: [:create]

  before_action :set_location, only: [:create]
  before_action :set_verification_object, only: [:verify]

  decorates_assigned :location

  def create
    tracker.track('createLocationOwnerVerification',
      email: params.fetch(:email, nil),
      owner: current_user,
      location: @location.to_param
    )

    @verification = LocationOwnerVerification.create(
      :email => params.fetch(:email, @location.email),
      :location => @location,
      :user => current_user
    )

    LocationOwnerVerificationMailer.verification_email(
      @verification,
      verify_verification_url(@verification.to_param, ref: 'email')).deliver

    respond_to do |format|
      format.json { render :status => :created, :partial => 'locations/location' }
      format.html { redirect_to location_path(@location, claimed: 1) }
    end
  end

  def verify
    tracker.track('verifyLocationOwner',
      email: @verification.email,
      owner: @verification.user.to_param,
      location: @verification.location.to_param
    )

    @verification.verify!
    redirect_to location_path(@verification.location, verified: 1)
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

