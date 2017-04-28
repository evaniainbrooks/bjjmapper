class Api::TeamsController < Api::ApiController
  include Api::TeamCreateParams
  
  before_action :set_team, only: [:show, :update, :remove_image, :destroy]

  def update
    @team.update!(api_team_create_params)

    respond_to do |format|
      format.json { render partial: 'teams/team' }
    end
  end

  private
  
  def set_team
    id_param = params.fetch(:id, '')
    @team = Team.find(id_param)
    render status: :not_found and return unless @team.present?
  end
end
