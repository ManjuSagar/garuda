class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def require_admin_login
    unless user_signed_in? and current_user.admin? 
      flash[:error] = "You must be logged in as admin to access this section"
      redirect_to new_transaction_url
    end
  end
end
