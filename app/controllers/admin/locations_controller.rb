class Admin::LocationsController < Admin::AdminController
  def meta
    @location = Location.find(params[:id])
  end

  def index
    @locations = Location.limit(50).sort({created_at:-1})
  end
end
