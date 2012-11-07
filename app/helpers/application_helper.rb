module ApplicationHelper

  def flash_alert
    content_tag :div, flash[:alert], class: "alert alert-error" if flash[:alert]
  end

  def flash_success
    content_tag :div, flash[:success], class: 'alert alert-success' if flash[:success]
  end

end
