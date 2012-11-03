module DeviseHelper
  def devise_error_messages!
    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }
    header   = content_tag :p, "#{pluralize(messages.count, 'error')} prevented the form from being saved:"
    content_tag :div, header + raw(messages.join), class: 'alert alert-error' if messages.any?
  end
end
