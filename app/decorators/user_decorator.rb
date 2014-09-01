class UserDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates :location

  def image
    object.image || 'default-user-100.png'
  end
  
  def rank_image
    "belt-#{object.belt_rank}-#{object.stripe_rank}.png" 
  end

  def rank_in_words
    belt_rank = object.belt_rank.try(:capitalize) || "White"
    stripe_rank = object.stripe_rank || 0
    "#{belt_rank} belt #{stripe_rank} stripes"
  end
end
