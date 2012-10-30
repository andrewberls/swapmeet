module ApplicationHelper

  def flash_alert
    content_tag :div, flash[:alert], class: "alert alert-error" if flash[:alert]
  end

end
