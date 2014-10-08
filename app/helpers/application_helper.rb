module ApplicationHelper
  def edit_mode_classes
    'editable' + (edit_mode? ? ' edit-mode' : '')
  end
  
  def edit_mode?
    current_user.present? && params.fetch(:edit, 0).to_i.eql?(1)
  end
end
