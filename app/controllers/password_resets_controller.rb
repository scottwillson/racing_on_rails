class PasswordResetsController < ApplicationController
  before_filter :require_no_user
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. Please check your email."
      redirect_to new_user_session_path
    else
      flash[:notice] = "No user was found with that email address"
      render :new
    end
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      @user_session = UserSession.create(@user)
      flash[:notice] = "Password successfully updated"
      if @user.administrator?
        redirect_back_or_default admin_home_url
      else
        redirect_back_or_default root_url
      end
    else
      render :edit
    end
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account. " +
        "Please try copying and pasting the URL " +
        "from your email into your browser or restarting the " +
        "reset password process."
      redirect_to root_url
    end
  end
end
