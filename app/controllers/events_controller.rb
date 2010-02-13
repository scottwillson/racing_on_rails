# For now, this controller only redirects to ScheduleController.
# Longer-term, this controller should handle the schedule.
class EventsController < ApplicationController
  def index
    if params[:person_id]
      @person = Person.find(params[:person_id])
      @events = @person.events.find(:all, :conditions => [ "date between ? and ?", ASSOCIATION.effective_today.beginning_of_year, ASSOCIATION.effective_today.end_of_year ])
    else
      redirect_to schedule_path
    end
  end
end
