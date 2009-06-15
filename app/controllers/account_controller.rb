# Deprecated. Just redirect over to UserSessionController
class AccountController < ApplicationController
  def index
    redirect_to new_user_session_path
  end
end
