class UserDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates :location

  DEFAULT_IMAGE = 'default-user-100.png'

  def image
    h.image_path(object.image || DEFAULT_IMAGE)
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
    "#{belt_rank.capitalize} belt #{stripe_rank} stripes"
  end

  def description
    if description_src.try(:to_sym).try(:eql?, :wikipedia)
      WikiCloth::Parser.new(data: object.description).to_html
    else
      object.description
    end
  end

  def summary
    @summary ||= if description_src.try(:to_sym).try(:eql?, :wikipedia)
      matchdata = description.match(/<p>(.*)<\/p>/)
      matchdata[1] if matchdata.present?
    end
  end
end
