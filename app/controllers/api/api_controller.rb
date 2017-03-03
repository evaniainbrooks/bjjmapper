class Api::ApiController <  ApplicationController
  before_action :ensure_api_user

  private

  def current_user
    @current_user ||= User.where(:api_key => params[:api_key]).first
  end

  def ensure_api_user
    head :forbidden and return false unless signed_in? && (current_user.super_user? || current_user.api_key.present?)
  end
end
