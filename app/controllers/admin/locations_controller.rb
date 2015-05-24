class Admin::LocationsController < Admin::AdminController
  def show
    id_param = params.fetch(:id, '').split('-', 2).first
    @location = Location.find(id_param)
  end

  def index
    @locations = Location.limit(50).sort({created_at:-1})
  end
end
