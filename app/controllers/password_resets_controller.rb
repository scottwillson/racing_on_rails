# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  before_action :load_person_using_perishable_token, only: %i[edit update]

  def create
    if params[:email].blank?
      flash[:notice] = "Please enter an email address"
      return render(:new)
    end

    @email = params[:email].strip
    @people = Person.where(email: @email).where("login is not null and login != ''")
    if @people.any?
      Person.deliver_password_reset_instructions!(@people)
      flash[:notice] = "Please check your email. We've sent you password reset instructions."
      redirect_to new_password_reset_url
    else
      flash[:notice] = "Can't find anyone with this email address"
      render :new
    end
  end

  def update
    @person.password = params[:person][:password]

    if @person.password.blank?
      flash[:warn] = "Please provide a new password"
      @person.errors.add(:password, "can't be blank") if @person.password.blank?
      return render(:edit)
    end

    if @person.save
      @person_session = PersonSession.create(@person)
      flash[:notice] = "Password changed"
      if @person.administrator?
        redirect_back_or_default admin_home_url
      else
        redirect_back_or_default "/account"
      end
    else
      render :edit
    end
  end

  private

  def load_person_using_perishable_token
    @person = Person.find_using_perishable_token(params[:id], 1.day)
    unless @person
      flash[:notice] = "We're sorry, but we could not locate your account. " \
                       "Please try copying and pasting the URL " \
                       "from your email into your browser or restarting the " \
                       "reset password process."
      redirect_to new_password_reset_path
    end
  end
end
