class ApplicationController < ActionController::Base
  # Just for testing
  #protect_from_forgery

  # Overwrite signout redirect back to login page
  def after_sign_out_path_for(resource_or_scope)
    login_path
  end

  def reject_unauthorized(authorized, path="/")
    unless authorized
      logger.warn "WARNING: Unauthorized access attempt"

      respond_to do |format|
        format.html { return redirect_to path }
        format.json { return render json: {} }
      end
    end
  end

end
