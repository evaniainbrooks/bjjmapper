class Admin::AdminController <  ApplicationController
  layout 'admin'
  before_action :ensure_super_user

  def index
    @feature_settings = FeatureSetting.all.to_a.collect{|o| o.attributes.slice(:name, :value)}

  end

  private

  def ensure_super_user
    head :forbidden and return false unless signed_in? && current_user.role.try(:to_sym).try(:eql?, :super_user)
  end
end
