class PasswordResetsController < ApplicationController
  before_filter :load_person_using_perishable_token, :only => [:edit, :update]
  ssl_required :create, :edit, :update, :new

  def create
    @person = Person.find_by_email(params[:email])
    if @person
      @person.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. Please check your email."
      redirect_to new_person_session_path
    else
      flash[:notice] = "No person was found with that email address"
      render :new
    end
  end

  def update
    @person.password = params[:person][:password]
    @person.password_confirmation = params[:person][:password_confirmation]
    if @person.save
      @person_session = PersonSession.create(@person)
      flash[:notice] = "Password successfully updated"
      if @person.administrator?
        redirect_back_or_default admin_home_url
      else
        redirect_back_or_default root_url
      end
    else
      render :edit
    end
  end

  private

  def load_person_using_perishable_token
    @person = Person.find_using_perishable_token(params[:id])
    unless @person
      flash[:notice] = "We're sorry, but we could not locate your account. " +
        "Please try copying and pasting the URL " +
        "from your email into your browser or restarting the " +
        "reset password process."
      redirect_to root_url
    end
  end
end
