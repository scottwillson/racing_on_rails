class EventsController < ApplicationController
  include Api::Events
  
  def index
    respond_to do |format|
      format.html {
        if params[:person_id]
          @person = Person.find(params[:person_id])
          @events = @person.events.find(
                      :all, 
                      :conditions => [ "date between ? and ?", ASSOCIATION.effective_today.beginning_of_year, ASSOCIATION.effective_today.end_of_year ])
        else
          redirect_to schedule_path
        end
      }
      format.xml { render :xml => events_as_xml }
      format.json { render :json => events_as_json }
    end
  end
end
