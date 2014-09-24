class TeamsController < ApplicationController
  before_filter :set_team, only: :show
  before_filter :set_teams, only: :index

  decorates_assigned :team, :teams

  def show
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

  private

  def set_teams
    @teams = Team.limit(50)
    render status: :not_found and return unless @teams.present?
  end

  def set_team
    @team = Team.find(params[:id])
    render status: :not_found and return unless @team.present?
  end
end
