class TeamsController < ApplicationController
  before_filter :set_team, only: :show
  
  decorates_assigned :team

  def show
    respond_to do |format|
      format.json { render json: @team }
      format.html 
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
    render status: :not_found and return unless @team.present?
  end
end
