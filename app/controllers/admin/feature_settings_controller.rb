class Admin::FeatureSettingsController < Admin::AdminController
  def index
    @feature_settings = FeatureSetting.all.to_a.collect{|o| o.attributes.slice(:name, :value)}

    respond_to do |format|
      format.json do
        render json: @feature_settings
      end
    end
  end
  
  def update
    name = params[:id]
    value = params.fetch(:value, 0).to_i

    FeatureSetting.enable(name, value == 1)

    head :ok
  end
end
