class ArticleDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :author

  def author_name
    object.author.name
  end

  def updated_at
    object.updated_at.present? ? "#{h.time_ago_in_words(object.updated_at).gsub('about ', '')} ago" : nil
  end

  def created_at
    object.created_at.present? ? "#{h.time_ago_in_words(object.created_at).gsub('about ', '')} ago" : nil
  end
end
