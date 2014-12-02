class SitemapsController < ApplicationController
  helper_method :locations
  helper_method :teams

  def index
    @locations = Location.all
    @teams = Team.all

    respond_to do |format|
      format.xml
    end
  end

  private

  def locations
    @locations
  end

  def teams
    @teams
  end
end
