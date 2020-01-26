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
    name = params[:name].try(:strip)
    year = RacingAssociation.current.effective_year.to_i if year.blank?

    if name.present?
      if params[:per_page]
        Event.year(year).name_like(name[0, 32]).paginate(page: page, per_page: params[:per_page])
      else
        Event.year(year).name_like(name[0, 32]).page(page)
      end
    else
      Event.year(year)
    end
  end
end
