class ApplicationController < ActionController::Base
  protect_from_forgery

  ACCESS_DENIED_PATH = '/'

  helper_method :current_user, :signed_in?

  def must_be_logged_in
    reject_unauthorized(signed_in?, login_path)
  end

  private

  def current_user
    # TODO: didn't copy over as not sure of exact auth strategy
  end

  def signed_in?
    current_user.present?
  end

  def reject_unauthorized(authorized, path=ACCESS_DENIED_PATH)
    respond_to do |format|
      format.html { return redirect_to path unless authorized }
      format.json { return render json: {} unless authorized }
    end
  end

end
