module ModerationNotificationCreateParams
  extend ActiveSupport::Concern
  
  def moderation_notification_create_params
    params.require(:notification).permit!
  end
end
