class LocationDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :head_instructor

  decorates :location


  def directions
    object.directions || h.content_tag(:i) { 'No extra directions were provided' }
  end

  def image
    object.image || 'academy-default-100.jpg'
  end

  def updated_at
    h.time_ago_in_words object.updated_at
  end

  def created_at
    h.time_ago_in_words object.created_at
  end
end
