class OrganizationDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'

  delegate_all
  decorates_finders

  def description
    if object.description.present?
      object.description
    else
      h.content_tag(:i, class: 'text-muted') { DEFAULT_DESCRIPTION }
    end
  end
end
