class InstructorsController < ApplicationController
  before_action :set_location_or_team
  before_action :set_instructor, only: [:destroy]

  decorates_assigned :location_or_team

  def index
    respond_to do |format|
      format.json
    end
  end

  def create
    @instructor = find_or_create_instructor
    @location_or_team.instructors << @instructor
    @location_or_team.save

    tracker.track('createInstructor',
      location: @location_or_team.to_param,
      id: @instructor.to_param,
      createdNewUser: params.key?(:user)
    )
    
    #if @location_or_team.instance_of? Location
    #  Activity.create({
    #    activity_type: Activity::TYPE_INSTRUCTOR_CREATED,
    #    coordinates: @location_or_team.coordinates,
    #    segment_key: @location_or_team.country,
    #    source_id: current_user.id.to_s,
    #    source_type: User.to_s,
    #    source_name: current_user.name.to_s,
    #    entity_id: @location_or_team.id.to_s,
    #    entity_type: Location.to_s,
    #    data: {
    #      location: @location_or_team.attributes,
    #      instructor: @instructor.attributes
    #    }
    #  })
    #end

    respond_to do |format|
      format.html { redirect_to polymorphic_path(@location_or_team, edit: 1) }
      format.json { render :json => {}, :status => :ok }
    end
  end

  def destroy
    tracker.track('deleteInstructor',
      id: @location_or_team.to_param,
      location: @location_or_team.to_param
    )

    @location_or_team.instructors.delete(@instructor)

    respond_to do |format|
      format.html { redirect_to polymorphic_path(@location_or_team, edit: 1) }
      format.json { render :json => {}, :status => :ok }
    end
  end

  private

  def find_or_create_instructor
    if params.key?(:user)
      User.create!(create_params)
    elsif params.fetch(:id, nil).present?
      User.find(params[:id])
    else
      User.create!(create_stub_params)
    end
  end

  def create_stub_params
    { name: params[:name], belt_rank: 'black', stripe_rank: 0, role: 'instructor_stub', flag_stub: true }
  end

  def create_params
    params.require(:user).permit(:name, :image, :email, :belt_rank, :stripe_rank, :birth_day, :birth_month, :birth_year, :lineal_parent_id, :birth_place, :description)
  end

  def set_location_or_team
    @location_or_team = if params.key?(:team_id)
      fetch_team
    else
      fetch_location
    end
    head :not_found and return false unless @location_or_team.present?
  end

  def fetch_team
    id_param = params.fetch(:team_id, '')
    Team.find(id_param)
  end

  def fetch_location
    id_param = params.fetch(:location_id, '')
    Location.find(id_param)
  end

  def set_instructor
    @instructor = @location_or_team.instructors.find(params[:id])
    head :not_found and return false unless @instructor.present?
  end
end
