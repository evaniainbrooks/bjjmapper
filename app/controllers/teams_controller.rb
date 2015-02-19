class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :update]
  before_action :set_teams, only: :index
  before_action :ensure_signed_in, only: [:update, :create, :new]

  decorates_assigned :team, :teams
  
  helper_method :created?

  def new
    @team = Team.new
    tracker.track('newTeam')
  end

  def create
    team = Team.create(create_params)

    tracker.track('createTeam',
      team: team.as_json({}),
      has_avatar: create_params[:avatar].present?
    )

    respond_to do |format|
      format.json { render json: team }
      format.html { redirect_to team_path(team, edit: 1, create: 1) }
    end
  end

  def show
    tracker.track('showTeam',
      id: @team.to_param
    )

    respond_to do |format|
      format.json { render json: @team }
      format.html
    end
  end

  def index
    respond_to do |format|
      format.json { render json: @teams }
    end
  end

  def update
    tracker.track('updateTeam',
      id: @team.to_param,
      team: @team.as_json({}),
      updates: create_params.except(:avatar),
      has_avatar: create_params[:avatar].present?
    )

    @team.update!(create_params)

    respond_to do |format|
      format.json { render json: @team }
      format.html { redirect_to team_path(@team, edit: 0) }
    end
  end

  private
  
  def created?
    return params.fetch(:create, 0).to_i.eql?(1)
  end

  def create_params
    p = params.require(:team).permit(:name, :description, :parent_team_id, :primary_color_index, :avatar, :modifier_id)
    p[:modifier_id] = current_user.to_param if signed_in?
    p
  end

  def set_teams
    @teams = Team.limit(50)
    render status: :not_found and return unless @teams.present?
  end

  def set_team
    id_param = params.fetch(:id, '').split('-', 2).first
    @team = Team.find(id_param)
    render status: :not_found and return unless @team.present?
  end
end
