class ModerationNotificationsController < ApplicationController
  decorates_assigned :notifications
  before_action :ensure_signed_in
  before_action :check_permissions

  def index
    count = params.fetch(:count, 20).to_i
    offset = params.fetch(:offset, 0).to_i
    lat = params.fetch(:lat, nil).try(:to_f)
    lng = params.fetch(:lng, nil).try(:to_f)
    distance = params.fetch(:distance, 25).to_i

    @notifications = ModerationNotification.where(:dismissed_by_user_id => nil).offset(offset).limit(count).order(created_at: :desc)

    @notifications = @notifications.near([lng, lat], distance) if lng.present? && lat.present?

    respond_to do |format|
      format.html
    end
  end

  def dismiss
    @notification = ModerationNotification.find(params[:id])
    @notification.dismiss!(current_user)

    head :accepted
  end

  private

  def check_permissions
    head :forbidden and return false unless Role.power(current_user.role) >= Role.power(Role::MODERATOR)
  end
end
