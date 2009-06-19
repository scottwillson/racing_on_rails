class PersonSessionsController < ApplicationController
  before_filter :require_person, :only => :destroy
  
  def new
    if current_person
      render :show
    else
      @person_session = PersonSession.new
    end
  end
  
  def create
    @person_session = PersonSession.new(params[:person_session])
    @person_session.remember_me = true
    if @person_session.save
      flash.discard
      if @person_session.person.administrator?
        redirect_back_or_default admin_home_url
      else
        redirect_back_or_default root_url
      end
    else
      render :action => :new
    end
  end
  
  def destroy
    current_person_session.destroy
    redirect_back_or_default new_person_session_url
  end
end
