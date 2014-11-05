module ApplicationHelper
  def belt_ranks
    ['white','blue','purple','brown','black'].map{|x| [x.capitalize,x]}
  end

  def stripe_ranks
    (0..10)
  end

  def select_days
    (1..31)
  end

  def select_months
    (1..12).map do |i|
      [Date::MONTHNAMES[i], i]
    end
  end

  def select_years
    (1900..2010)
  end
  
  def all_instructors
    User.where(:role => 'instructor').limit(200).sort_by(&:name)
  end
  
  def select_instructors
    all_instructors.map { |instructor| [instructor.name, instructor.id, {'data-img-src' => instructor.image}] }
  end  

  def edit_mode_classes
    'editable' + (edit_mode? ? ' edit-mode' : '')
  end
  
  def edit_mode?
    current_user.present? && params.fetch(:edit, 0).to_i.eql?(1)
  end
end
