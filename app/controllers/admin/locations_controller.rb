class Admin::LocationsController < Admin::AdminController
  def show
    id_param = params.fetch(:id, '')
    @location = Location.find(id_param)
  end

  def index
    @locations = Location.limit(100).sort({created_at:-1})
  end

  def pending
    @locations = Location.limit(100).pending.sort({created_at:-1})
  end

  def rejected
    @locations = Location.limit(100).rejected.sort({created_at:-1})
  end
end
