class ReviewDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :location
  decorates_association :user

  def attribution_name
    if object.author_name.present?
      object.author_name
    else
      user.name
    end
  end

  def attribution_link
    if object.author_name.present?
      object.author_link
    else
      h.user_path(object.user)
    end
  end

  def src
    if object.src.present?
      object.src
    else
      'BJJMapper'
    end
  end
end
