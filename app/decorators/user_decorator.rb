class UserDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates :location

  DEFAULT_IMAGE = 'default-user-100.png'

  def image
    object.image || DEFAULT_IMAGE 
  end

  def belt_rank
    object.belt_rank || 'white'
  end

  def stripe_rank
    object.stripe_rank || 0
  end

  def rank_image
    h.path_to_asset("belts/#{belt_rank}#{stripe_rank}.png", type: :image)
  end

  def rank_in_words
    "#{belt_rank.capitalize} belt #{stripe_rank} stripes"
  end
end
