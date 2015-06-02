module UsersHelper
  def upload_image_user_path(user)
    "/service/avatar/upload/users/#{user.id}/async"
  end
  
  def all_instructors
    User.jitsukas.limit(1000).sort_by(&:name)
  end

  def select_instructors
    all_instructors.map { |instructor| [instructor.name, instructor.id, {'data-img-src' => image_path(instructor.image)}] }
  end

  def all_instructors_groups
    UserDecorator.decorate_collection(all_instructors).group_by(&:belt_rank)
  end

  def all_instructors_select_groups
    groups = all_instructors_groups
    groups.map do |belt_rank, member_group|
      [
        belt_rank.capitalize, member_group.map do |u| 
          [u.name, u.id.to_s, {:'data-img-src' => u.image}] 
        end
      ]
    end.sort_by { |arr| User.rank_sort_key(arr[0], 0) }
  end
end
