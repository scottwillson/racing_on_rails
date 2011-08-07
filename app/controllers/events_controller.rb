# Longer-term, this controller should handle the schedule
class EventsController < ApplicationController
  include Api::Events

  ssl_allowed :index
  
  # HTML: Event dashboard for promoter (Person)
  # XML, JSON: Remote API
  # == Params
  # * person_id
  #
  # == Returns
  # JSON and XML results are paginated with a page size of 10
  # * event: [ :id, :parent_id, :name, :type, :discipline, :city, :cancelled, :beginner_friendly ]
  # * race: [ :id, :distance, :city, :state, :laps, :field_size, :time, :finishers, :notes ]
  # * category: [ :id, :name, :ages_begin, :ages_end, :friendly_param ]
  #
  # See source code of Api::Events and Api::Base
  def index
    respond_to do |format|
      format.html {
        if params[:person_id]
          @person = Person.find(params[:person_id])
          @events = @person.events.all(
            :conditions => [ 
              "date between ? and ?", 
              RacingAssociation.current.effective_today.beginning_of_year, 
              RacingAssociation.current.effective_today.end_of_year
             ])
        else
          redirect_to schedule_path
        end
      }
      format.xml { render :xml => events_as_xml }
      format.json { render :json => events_as_json }
    end
  end

  def show
    respond_to do |format|
      format.xml { render :xml => event_as_xml }
      format.json { render :json => event_as_json }
    end
  end
end
