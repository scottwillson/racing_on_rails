# Deprecated. Just redirect over to PersonSessionController
class AccountController < ApplicationController
  def index
    if current_person
      redirect_back_or_default admin_home_url
    else
      redirect_to new_person_session_path
    end
  end
end
