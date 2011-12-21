class PersonSessionsController < ApplicationController
  before_filter :require_current_person, :only => :show
  
  def new
    if current_person
      return render(:show)
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
    current_person_session.destroy if current_person_session
    redirect_back_or_default new_person_session_url(secure_redirect_options)
  end
end
