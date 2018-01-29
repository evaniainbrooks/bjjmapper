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

  def select_recurrence
    [['None', 0],['Daily', 1],['Every second day', 2], ['Weekly', 3], ['Bi-weekly', 4]]
  end

  def edit_mode_classes
    'editable' + (edit_mode? ? ' edit-mode' : '')
  end

  def edit_mode?
    current_user.present? && params.fetch(:edit, 0).to_i.eql?(1)
  end

  def edit_success?
    params.fetch(:success, 0).to_i.eql?(1)
  end

  def render_json(object, options = {})
    sym = object.model_name.to_s.underscore
    directory = sym.pluralize
    partial = options[:partial] || sym
    options = {
      :partial => "#{directory}/#{partial}",
      :locals => { sym.to_sym => object },
      :formats => [:json]
    }
    return render(options)
  end

  def meta_tag(tag, text)
    content_for(:"meta_#{tag}", text)
  end

  def yield_meta_tag(tag, default_text)
    content_for?(:"#meta_#{tag}") ? content_for(:"meta_#{tag}") : default_text
  end
end
