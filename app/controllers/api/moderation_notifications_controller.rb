class Api::ModerationNotificationsController < Api::ApiController
  include ModerationNotificationCreateParams
  
  def create
    @notification = ModerationNotification.create(moderation_notification_create_params)
    puts @notification.errors.messages
    head :created
  end
end
