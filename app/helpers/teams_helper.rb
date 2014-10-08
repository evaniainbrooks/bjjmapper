module TeamsHelper
  def all_teams
    Team.all.limit(50).order_by(&:name).decorate
  end

  def all_teams_select_options
    all_teams.map { |team| [team.name, team.id] }
  end
end
