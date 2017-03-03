class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :update, :remove_image, :destroy]
  before_action :redirect_legacy_bsonid, only: [:show, :update, :remove_image, :destroy]
  before_action :set_teams, only: :index
  before_action :ensure_signed_in, only: [:update, :create, :new, :remove_image, :destroy]

  before_action :check_permissions, only: [:update, :destroy]

  decorates_assigned :team, :teams

  helper_method :created?
  helper_method :map

  def new
    @team = Team.new
    tracker.track('newTeam')
  end

  def create
    @team = Team.create(create_params)

    tracker.track('createTeam',
      team: @team.attributes.as_json({}),
      has_avatar: create_params[:avatar].present?
    )

    respond_to do |format|
      format.json { render partial: 'teams/team' }
      format.html { redirect_to team_path(@team, edit: 1, create: 1) }
    end
  end

  def destroy
    tracker.track('deleteTeam',
      id: @team.to_param,
      location: @team.attributes.as_json({})
    )

    @team.destroy

    respond_to do |format|
      format.html { redirect_to directory_index_path }
      format.json { render partial: 'teams/team' }
    end
  end

  def show
    tracker.track('showTeam',
      id: @team.to_param
    )

    respond_to do |format|
      format.json { render partial: 'teams/team' }
      format.html
    end
  end

  def index
    respond_to do |format|
      format.json
    end
  end

  def remove_image
    tracker.track('removeTeamImage',
      id: @team.to_param,
      image: @team.image
    )

    @team.update!({
      :image => nil,
      :image_large => nil,
      :image_tiny => nil
    })

    respond_to do |format|
      format.json { render partial: 'teams/team' }
    end
  end

  def update
    tracker.track('updateTeam',
      id: @team.to_param,
      team: @team.attributes.as_json({}),
      updates: create_params.except(:avatar),
      has_avatar: create_params[:avatar].present?
    )

    @team.update!(create_params)

    respond_to do |format|
      format.json { render partial: 'teams/team' }
      format.html { redirect_to team_path(@team, edit: 0) }
    end
  end

  private

  def map
    @_map ||= Map.new(
      location_type: [Location::LOCATION_TYPE_ACADEMY],
      event_type: [],
      lat: 50.0,
      lng: 0.0,
      team: [@team.id.to_s],
      distance: 10000.0,
      zoom: 2,
      minZoom: 2,
      geolocate: 0,
      refresh: 0
    )
  end

  def check_permissions
    if request.delete?
      head :forbidden and return false unless current_user.can_edit?(@team)
    else
      head :forbidden and return false unless current_user.can_destroy?(@team)
    end
  end

  def created?
    return params.fetch(:create, 0).to_i.eql?(1)
  end

  def create_params
    p = params.require(:team).permit(:name, :description, :parent_team_id, :primary_color_index, :modifier_id, :ig_hashtag)
    p[:modifier] = current_user if signed_in?
    p
  end

  def redirect_legacy_bsonid
    redirect_legacy_bsonid_for(@team, params[:id])
  end

  def set_teams
    @teams = Team.limit(50)
    render status: :not_found and return unless @teams.present?
  end

  def set_team
    id_param = params.fetch(:id, '')
    @team = Team.find(id_param)
    render status: :not_found and return unless @team.present?
  end
end
