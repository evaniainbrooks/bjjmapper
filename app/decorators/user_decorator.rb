class UserDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates :user
  decorates_association :lineal_parent
  decorates_association :lineal_children
  decorates_association :locations
  decorates_association :favorite_locations

  DEFAULT_IMAGE = '//storage.googleapis.com/bjjmapper/default-user-250.png'
  DEFAULT_DESCRIPTION = 'No description was provided'

  def description?
    object.description.present?
  end

  def description
    if object.description.present?
      object.description
    else
      h.content_tag(:i, class: 'text-muted') { DEFAULT_DESCRIPTION }
    end
  end

  def image?
    object.image.present?
  end

  def image
    h.image_url(object.image || DEFAULT_IMAGE)
  end

  def belt_rank
    object.belt_rank || 'white'
  end

  def stripe_rank
    object.stripe_rank || 0
  end

  def full_name
    if nickname.blank?
      name
    else
      components = name.split(' ', 2)
      "#{components[0]} \"#{nickname}\" #{components[1]}"
    end
  end

  def descriptive_rank_in_words
    if object.belt_rank == 'black'
      if object.stripe_rank > 0
        "#{stripe_rank.ordinalize} degree #{belt_rank} belt"
      else
        "black belt"
      end
    else
      rank_in_words
    end
  end

  def rank_in_words
    "#{belt_rank.capitalize} belt"
  end

  #def description
    #if description_src.try(:to_sym).try(:eql?, :wikipedia)
    #  WikiCloth::Parser.new(data: object.description).to_html
    #else
    #  object.description
    #end
  #end

  def summary
    if description_src.try(:to_sym).try(:eql?, :wikipedia)
      matchdata = description.match(/<p>(.*)<\/p>/)
      matchdata[1] if matchdata.present?
    end
  end
end
