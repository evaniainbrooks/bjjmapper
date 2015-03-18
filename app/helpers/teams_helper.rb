module TeamsHelper
  def all_teams
    Team.all.limit(50).to_a.sort_by(&:name)
  end
  def all_teams_groups
    teams = TeamDecorator.decorate_collection(all_teams)
    grouped_teams = {}
    teams.each do |team|
      grouped_teams[team.parent_team_id] ||= []
      grouped_teams[team.parent_team_id] << team
    end
    grouped_teams
  end
  def all_teams_select_groups
    grouped_teams = all_teams_groups
    grouped_teams.each_pair do |parent_team, member_group|
      member_group.reject!{|team| grouped_teams[team] } if parent_team.blank?
      member_group.unshift(parent_team) if parent_team.present?
    end.map do |parent_team, member_group|
      [parent_team.try(:name) || 'Teams', member_group.map { |team| team=team.decorate; [team.name, team.id.to_s, {:'data-img-src' => team.image}] }]
    end
  end
  def all_teams_select_options
    all_teams.map { |team| [team.name, team.id, {:'data-img-src' => team.image}] }
  end
end
