module DeviseHelper
  def devise_error_messages!
    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    header   = content_tag :p, "Something went wrong - please check your fields and try again."
    content_tag :div, header + raw(messages), class: 'alert alert-error'
  end
end
