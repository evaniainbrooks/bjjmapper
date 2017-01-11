module UsersHelper
  def upload_image_user_path(user)
    "/service/avatar/upload/users/#{user.id}/async"
  end
end
