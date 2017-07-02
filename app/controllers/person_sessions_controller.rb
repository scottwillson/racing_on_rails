# frozen_string_literal: true

class PersonSessionsController < ApplicationController
  force_https
  before_action :require_current_person, only: :show

  def new
    if current_person
      render(:show)
    else
      @person_session = PersonSession.new
    end
  end

  def create
    @person_session = PersonSession.new(person_session_params)
    @person_session.remember_me = true
    if @person_session.save
      flash.discard
      if @person_session.person.administrator?
        redirect_back_or_default admin_home_url(secure_redirect_options)
      else
        redirect_back_or_default edit_person_url(@person_session.person, secure_redirect_options)
      end
    else
      render :new
    end
  end

  def destroy
    session[:return_to] = nil
    current_person_session&.destroy
    flash[:notice] = "You are logged-out"
    redirect_back_or_default new_person_session_url(secure_redirect_options)
  end

  private

  def person_session_params
    params_without_mobile.require(:person_session).permit(:email, :login, :password)
  end
end
