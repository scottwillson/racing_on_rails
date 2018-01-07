# frozen_string_literal: true

# Longer-term, this controller should handle the schedule
class EventsController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        if params[:person_id]
          @person = Person.find(params[:person_id])
          @events = Event.editable_by(@person).current_year_and_later
        else
          redirect_to schedule_path
        end
      end
      format.json { render json: events_for_api(params[:year]) }
      format.xml { render xml: events_for_api(params[:year]).to_xml }
    end
  end

  private

  def events_for_api(year)
    year = RacingAssociation.current.effective_year if year.blank?
    Event.year year.to_i
  end
end
