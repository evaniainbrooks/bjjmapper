class Admin::AdminController <  ApplicationController
  layout 'admin'
  before_action :ensure_super_user

  private

  def ensure_super_user
    head :forbidden and return false unless signed_in? && current_user.role.try(:to_sym).try(:eql?, :super_user)
  end
end
