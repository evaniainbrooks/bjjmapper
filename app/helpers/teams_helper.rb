module TeamsHelper
  def upload_image_team_path(team)
    "/service/avatar/upload/teams/#{team.id}/async"
  end
  def all_teams
    Team.all.limit(100).to_a.sort_by(&:name)
  end
  def all_teams_groups
    teams = TeamDecorator.decorate_collection(all_teams)
    grouped_teams = {}
    teams.each do |team|
      grouped_teams[team.parent_team.try(:to_param)] ||= (team.parent_team.present? ? [team.parent_team] : [])
      grouped_teams[team.parent_team.try(:to_param)] << team
    end
    grouped_teams
  end
  def all_teams_select_groups
    grouped_teams = all_teams_groups
    grouped_teams.each_pair do |parent_team_id, member_group|
      member_group.reject!{|team| grouped_teams[team.to_param] } if parent_team_id.blank?
    end.map do |parent_team_id, member_group|
      [parent_team_id.present? ? member_group[0].name : ' Teams', member_group.map { |team| team=team.decorate; [team.name, team.id.to_s, {:'data-img-src' => team.image}] }]
    end.sort
  end
  def all_teams_select_options
    all_teams.map { |team| [team.name, team.id, {:'data-img-src' => team.image}] }
  end
end
