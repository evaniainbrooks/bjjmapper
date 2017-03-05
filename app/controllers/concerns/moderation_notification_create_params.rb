module ModerationNotificationCreateParams
  extend ActiveSupport::Concern
  
  def moderation_notification_create_params
    p = params.require(:notification).permit!
    p[:coordinates] = [p[:lng], p[:lat]] if p[:coordinates].blank?
    p
  end
end
