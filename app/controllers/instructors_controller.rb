class InstructorsController < ApplicationController
  before_action :set_location_or_team
  before_action :set_instructor, only: [:destroy]
  before_action :set_instructors, only: [:index]

  decorates_assigned :instructors

  def index
    respond_to do |format|
      format.json { render status: :ok, json: instructors }
    end
  end

  def create
    @instructor = find_or_create_instructor
    @location_or_team.instructors << @instructor

    tracker.track('createInstructor',
      location: @location_or_team.to_param,
      id: @instructor.to_param,
      createdNewUser: params.key?(:user)
    )

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

  def set_instructors
    @instructors = @location_or_team.instructors
    render(status: :no_content, json: {}) and return false if @instructors.empty?
  end

  def find_or_create_instructor
    if params.key?(:user)
      User.create!(create_params)
    else
      User.find(params[:id])
    end
  end

  def create_params
    params.require(:user).permit(:name, :image, :email, :belt_rank, :stripe_rank, :birth_day, :birth_month, :birth_year, :lineal_parent, :birth_place, :description)
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
    id_param = params.fetch(:team_id, '').split('-', 2).first
    Team.find(id_param)
  end

  def fetch_location
    id_param = params.fetch(:location_id, '').split('-', 2).first
    Location.find(id_param)
  end

  def set_instructor
    @instructor = @location_or_team.instructors.find(params[:id])
    head :not_found and return false unless @instructor.present?
  end
end
