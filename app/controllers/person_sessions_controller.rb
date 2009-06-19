class PersonSessionsController < ApplicationController
  before_filter :require_user, :only => :destroy
  
  def new
    if current_user
      render :show
    else
      @user_session = UserSession.new
    end
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    @user_session.remember_me = true
    if @user_session.save
      flash.discard
      if @user_session.user.administrator?
        redirect_back_or_default admin_home_url
      else
        redirect_back_or_default root_url
      end
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    redirect_back_or_default new_user_session_url
  end
end
