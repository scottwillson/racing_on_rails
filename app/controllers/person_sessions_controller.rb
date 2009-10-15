class PersonSessionsController < ApplicationController
  ssl_required :new, :create, :destroy

  before_filter :require_person, :only => [ :destroy, :show ]
  
  def new
    if current_person
      return render :show
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
        redirect_back_or_default edit_person_path(@person_session.person)
      end
    else
      render :new
    end
  end
  
  def destroy
    current_person_session.destroy if current_person_session
    redirect_back_or_default new_person_session_url
  end
end
