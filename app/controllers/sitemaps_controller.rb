class SitemapsController < ApplicationController
  helper_method :locations
  helper_method :teams
  helper_method :users

  def index
    @locations = Location.all
    @teams = Team.all
    @users = User.jitsukas
    respond_to do |format|
      format.xml
    end
  end

  private

  def users
    @users
  end

  def locations
    @locations
  end

  def teams
    @teams
  end
end
