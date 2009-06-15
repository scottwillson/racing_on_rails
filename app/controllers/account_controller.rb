# Deprecated. Just redirect over to UserSessionController
class AccountController < ApplicationController
  def index
    if current_user
      redirect_back_or_default admin_home_url
    else
      redirect_to new_user_session_path
    end
  end
end
