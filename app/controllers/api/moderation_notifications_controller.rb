class Api::ModerationNotificationsController < Api::ApiController
  include ModerationNotificationCreateParams
  
  def create
    @notification = ModerationNotification.create(moderation_notification_create_params)
    head :created
  end
end
