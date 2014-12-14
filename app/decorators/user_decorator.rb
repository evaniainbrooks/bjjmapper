class UserDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates :user
  decorates_association :lineal_parent
  decorates_association :lineal_children
  decorates_association :locations

  DEFAULT_IMAGE = 'default-user-250.png'
  DEFAULT_DESCRIPTION = 'No description was provided'

  def description
    if object.description.present?
      object.description
    else
      h.content_tag(:i) { DEFAULT_DESCRIPTION }
    end
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

  def rank_image
    h.image_path("belts/#{belt_rank}#{[stripe_rank, 7].min}.png")
  end

  def rank_in_words
    "#{belt_rank.capitalize} belt"
  end

  def description
    #if description_src.try(:to_sym).try(:eql?, :wikipedia)
    #  WikiCloth::Parser.new(data: object.description).to_html
    #else
      object.description
    #end
  end

  def summary
    if description_src.try(:to_sym).try(:eql?, :wikipedia)
      matchdata = description.match(/<p>(.*)<\/p>/)
      matchdata[1] if matchdata.present?
    end
  end

  def as_json(args)
    object.as_json(args).symbolize_keys.merge(
      image: image,
      rank_in_words: rank_in_words
    )
  end
end
